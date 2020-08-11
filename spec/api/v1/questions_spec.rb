RSpec.describe 'API Questions', type: :api do
  let(:me) { create(:user) }
  let(:attachment) { build(:attachment) }
  let(:valid_attributes) { attributes_for(:question).merge(attachments_attributes: { "0": { file: attachment.file } }) }
  let(:invalid_attributes) { attributes_for(:question_invalid) }

  describe 'GET /api/v1/questions' do
    let!(:questions) { create_list(:question, 5) }
    let(:question) { questions.first }

    context 'when unauthorized' do
      before { get '/api/v1/questions', format: :json }

      it 'returns 200 status' do
        expect(last_response.status).to eq 200
      end

      it 'returns all questions' do
        expect(last_response.body).to have_json_size(questions.count)
      end
    end

    context 'when authorized' do
      before do
        sign_in_as_a_valid_user(me)
        get '/api/v1/questions', format: :json
      end

      it 'returns 200 status' do
        expect(last_response.status).to eq 200
      end

      it 'returns all questions' do
        expect(last_response.body).to have_json_size(questions.count)
      end

      %w[id title body attachments answers comments].each do |attr|
        it "contains #{attr}" do
          expect(last_response.body).to be_json_eql(question.public_send(attr.to_sym).to_json).at_path("0/#{attr}")
        end
      end
    end
  end

  describe 'GET /api/v1/questions/:id' do
    let!(:question) { create(:question, :with_comment, :with_file) }

    context 'when unauthorized' do
      before { get "/api/v1/questions/#{question.id}", format: :json }

      it 'returns 200 status' do
        expect(last_response.status).to eq 200
      end
    end

    context 'when authorized' do
      before do
        sign_in_as_a_valid_user(me)
        get "/api/v1/questions/#{question.id}", format: :json
      end

      it 'returns 200 status' do
        expect(last_response.status).to eq 200
      end

      %w[id title body].each do |attr|
        it "contains #{attr}" do
          expect(last_response.body).to be_json_eql(question.public_send(attr.to_sym).to_json).at_path(attr.to_s)
        end
      end

      it_behaves_like 'comments' do
        let(:resource) { question }
      end

      it_behaves_like 'attachments' do
        let(:resource) { question }
      end
    end
  end

  describe 'POST /api/v1/questions' do
    it_behaves_like 'unauthorized_api', :post do
      let(:path) { '/api/v1/questions' }
    end

    context 'when authorized' do
      context 'with valid attributes' do
        before do
          sign_in_as_a_valid_user(me)
          post '/api/v1/questions', format: :json, question: valid_attributes
        end

        it 'returns 201 status' do
          expect(last_response.status).to eq 201
        end

        it 'saves valid question' do
          expect do
            post '/api/v1/questions', format: :json, question: valid_attributes
          end.to change(Question, :count).by(1)
        end

        it 'saves attachment' do
          expect do
            post '/api/v1/questions', format: :json, question: valid_attributes
          end.to change(Attachment, :count).by(1)
        end

        %w[title body].each do |attr|
          it "contains #{attr}" do
            expect(last_response.body).to be_json_eql(valid_attributes[attr.to_sym].to_json).at_path(attr.to_s)
          end
        end

        it 'contains id' do
          expect(last_response.body).to have_json_path('id')
        end

        it_behaves_like 'action cable broadcast', QuestionSerializer, 'question', 'create' do
          let(:request_for) do
            post '/api/v1/questions', format: :json, question: valid_attributes
          end
          let(:channel) { 'questions' }
        end
      end

      context 'with invalid attributes' do
        before do
          sign_in_as_a_valid_user(me)
          post '/api/v1/questions', format: :json, question: invalid_attributes
        end

        it 'returns 422 status' do
          expect(last_response.status).to eq 422
        end

        it 'does not save valid question' do
          expect do
            post '/api/v1/questions', format: :json, question: invalid_attributes
          end.not_to change(Question, :count)
        end

        it 'contains errors' do
          expect(last_response.body).to have_json_path('errors')
        end
      end
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let!(:question) { create(:question, user: me) }

    it_behaves_like 'unauthorized_api', :patch do
      let(:path) { "/api/v1/questions/#{question.id}" }
    end

    context 'when authorized' do
      let(:invalid_attributes) { attributes_for(:question_invalid) }

      context 'with valid attributes' do
        before do
          sign_in_as_a_valid_user(me)
          patch "/api/v1/questions/#{question.id}", format: :json, question: valid_attributes
        end

        it 'returns 204 status' do
          expect(last_response.status).to eq 204
        end

        it_behaves_like 'action cable broadcast', QuestionSerializer, 'question', 'update' do
          let(:request_for) do
            patch "/api/v1/questions/#{question.id}", format: :json, question: valid_attributes
          end
          let(:channel) { 'questions' }
        end
      end

      context 'with invalid attributes' do
        before do
          sign_in_as_a_valid_user(me)
          patch "/api/v1/questions/#{question.id}", format: :json, question: invalid_attributes
        end

        it 'returns 422 status' do
          expect(last_response.status).to eq 422
        end

        %w[title body].each do |attr|
          it 'does not update question' do
            expect do
              patch "/api/v1/questions/#{question.id}", format: :json, question: invalid_attributes
            end.not_to change(question, attr)
          end
        end

        it 'contains errors' do
          expect(last_response.body).to have_json_path('errors')
        end
      end
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let!(:question) { create(:question, user: me) }

    it_behaves_like 'unauthorized_api', :delete do
      let(:path) { "/api/v1/questions/#{question.id}" }
    end

    context 'when authorized' do
      before { sign_in_as_a_valid_user(me) }

      it 'deletes question' do
        expect do
          delete "/api/v1/questions/#{question.id}", format: :json
        end.to change(Question, :count).by(-1)
      end

      it_behaves_like 'action cable broadcast', QuestionSerializer, 'question', 'destroy' do
        let(:request_for) do
          delete "/api/v1/questions/#{question.id}", format: :json
        end
        let(:channel) { 'questions' }
      end
    end
  end

  it_behaves_like 'api_attachments', 'question' do
    let(:user) { me }
    let(:post_path) { '/api/v1/questions' }
    let(:patch_path) { '/api/v1/questions' }
  end
end
