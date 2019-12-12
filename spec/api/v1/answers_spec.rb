RSpec.describe 'Questions API' do
  let(:question) { create(:question) }
  let(:answer) { create(:answer, :with_comment, :with_file) }

  describe '/index' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api' do
        let(:path) { "/api/v1/questions/#{answer.question.id}/answers" }
      end
    end

    context 'when authorized' do
      let!(:me) { create(:user) }
      let!(:answers) { create_list(:answer, 5, question: question) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }
      let(:first_answer) { answers.first }

      before do
        get "/api/v1/questions/#{question.id}/answers", params: { access_token: access_token.token,
                                                                  format: :json }
      end

      it 'returns 200 status' do
        expect(response.status).to eq 200
      end

      it 'returns all questions' do
        expect(response.body).to have_json_size(5)
      end

      %w[id body].each do |attr|
        it "contains #{attr}" do
          expect(response.body).to be_json_eql(first_answer.public_send(attr.to_sym).to_json).at_path("0/#{attr}")
        end
      end
    end
  end

  describe '/show' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api' do
        let(:path) { "/api/v1/answers/#{answer.id}" }
      end
    end

    context 'when authorized' do
      let!(:me) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before do
        get "/api/v1/answers/#{answer.id}",
            params: { id: answer, access_token: access_token.token, format: :json }
      end

      it 'returns 200 status' do
        expect(response.status).to eq 200
      end

      it_behaves_like 'comments' do
        let(:resource) { answer }
      end

      it_behaves_like 'attachments' do
        let(:resource) { answer }
      end
    end
  end

  describe '/create' do
    let(:valid_attributes) { attributes_for(:answer) }
    let(:invalid_attributes) { attributes_for(:invalid_answer) }

    context 'when unauthorized' do
      it 'returns 401 status if there in no access token' do
        post "/api/v1/questions/#{question.id}/answers",
             params: { format: :json, answer: valid_attributes, question: question }
        expect(response.status).to eq 401
      end

      it 'returns 401 status if access token is invalid' do
        post "/api/v1/questions/#{question.id}/answers",
             params: { access_token: '1234', format: :json, answer: valid_attributes, question: valid_attributes }
        expect(response.status).to eq 401
      end
    end

    context 'when authorized' do
      let!(:me) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      context 'with valid attributes' do
        before do
          post "/api/v1/questions/#{question.id}/answers",
               params: { format: :json, answer: valid_attributes, question: question, access_token: access_token.token }
        end

        it 'returns 201 status' do
          expect(response.status).to eq 201
        end

        it 'saves valid answer' do
          expect do
            post "/api/v1/questions/#{question.id}/answers", params: { access_token: access_token.token,
                                                                       format: :json,
                                                                       question: valid_attributes,
                                                                       answer: valid_attributes }
          end.to change(Answer, :count).by(1)
        end

        it 'contains body' do
          expect(response.body).to be_json_eql(valid_attributes[:body].to_json).at_path('body')
        end
      end

      context 'with invalid attributes' do
        before do
          post "/api/v1/questions/#{question.id}/answers", params: { access_token: access_token.token,
                                                                     format: :json,
                                                                     question: question,
                                                                     answer: invalid_attributes }
        end

        it 'returns 422 status' do
          expect(response.status).to eq 422
        end

        it 'does not save valid answer' do
          expect do
            post "/api/v1/questions/#{question.id}/answers", params: { access_token: access_token.token,
                                                                       format: :json,
                                                                       question: question,
                                                                       answer: invalid_attributes }
          end.not_to change(Answer, :count)
        end

        it 'contains errors' do
          expect(response.body).to have_json_path('errors')
        end
      end
    end
  end
end
