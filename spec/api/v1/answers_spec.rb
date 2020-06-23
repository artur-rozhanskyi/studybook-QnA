RSpec.describe 'Questions API', type: :api do
  let(:me) { create(:user) }
  let(:question) { create(:question) }

  describe 'GET #index' do
    let!(:answers) { create_list(:answer, 5, question: question) }
    let(:first_answer) { answers.first }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :get do
        let(:path) { "/api/v1/questions/#{question.id}/answers.json" }
      end
    end

    context 'when authorized' do
      before do
        sign_in_as_a_valid_user(me)
        get "/api/v1/questions/#{question.id}/answers.json"
      end

      it 'returns 200 status' do
        expect(last_response.status).to eq 200
      end

      it 'returns all questions' do
        expect(last_response.body).to have_json_size(5)
      end

      %w[id body].each do |attr|
        it "contains #{attr}" do
          expect(last_response.body).to be_json_eql(first_answer.public_send(attr.to_sym).to_json).at_path("0/#{attr}")
        end
      end
    end
  end

  describe 'GET #show' do
    let(:answer) { create(:answer, :with_comment, :with_file, question: question) }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :get do
        let(:path) { "/api/v1/answers/#{answer.id}.json" }
      end
    end

    context 'when authorized' do
      before do
        sign_in_as_a_valid_user(me)
        get "/api/v1/answers/#{answer.id}.json"
      end

      it 'returns 200 status' do
        expect(last_response.status).to eq 200
      end

      it_behaves_like 'comments' do
        let(:resource) { answer }
      end

      it_behaves_like 'attachments' do
        let(:resource) { answer }
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:answer) }
    let(:invalid_attributes) { attributes_for(:invalid_answer) }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :post do
        let(:path) { "/api/v1/questions/#{question.id}/answers.json" }
      end
    end

    context 'when authorized' do
      context 'with valid attributes' do
        before do
          sign_in_as_a_valid_user(me)
          post "/api/v1/questions/#{question.id}/answers.json", answer: valid_attributes, question: question
        end

        it 'returns 201 status' do
          expect(last_response.status).to eq 201
        end

        it 'saves valid answer' do
          expect do
            post "/api/v1/questions/#{question.id}/answers.json", question: valid_attributes, answer: valid_attributes
          end.to change(Answer, :count).by(1)
        end

        it 'contains body' do
          expect(last_response.body).to be_json_eql(valid_attributes[:body].to_json).at_path('body')
        end
      end

      context 'with invalid attributes' do
        before do
          sign_in_as_a_valid_user(me)
          post "/api/v1/questions/#{question.id}/answers.json", question: question, answer: invalid_attributes
        end

        it 'returns 422 status' do
          expect(last_response.status).to eq 422
        end

        it 'does not save invalid answer' do
          expect do
            post "/api/v1/questions/#{question.id}/answers.json", question: question, answer: invalid_attributes
          end.not_to change(Answer, :count)
        end

        it 'contains errors' do
          expect(last_response.body).to have_json_path('errors')
        end
      end
    end
  end
end
