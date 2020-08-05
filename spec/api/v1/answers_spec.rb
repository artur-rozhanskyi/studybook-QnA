RSpec.describe 'Answers API', type: :api do
  let(:me) { create(:user) }
  let(:question) { create(:question) }
  let(:valid_attributes) { attributes_for(:answer) }
  let(:invalid_attributes) { attributes_for(:invalid_answer) }

  describe 'GET /api/v1/questions/:id/answers' do
    let!(:answers) { create_list(:answer, 5, question: question) }
    let(:first_answer) { answers.first }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :get do
        let(:path) { "/api/v1/questions/#{question.id}/answers" }
      end
    end

    context 'when authorized' do
      before do
        sign_in_as_a_valid_user(me)
        get "/api/v1/questions/#{question.id}/answers", format: :json
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

  describe 'GET /api/v1/answers/:id' do
    let(:answer) { create(:answer, :with_comment, :with_file, question: question) }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :get do
        let(:path) { "/api/v1/answers/#{answer.id}" }
      end
    end

    context 'when authorized' do
      before do
        sign_in_as_a_valid_user(me)
        get "/api/v1/answers/#{answer.id}", format: :json
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

  describe 'POST /api/v1/questions/:id/answers' do
    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :post do
        let(:path) { "/api/v1/questions/#{question.id}/answers" }
      end
    end

    context 'when authorized' do
      let(:fake_serializer) { object_double(AnswerSerializer, as_json: '') }

      before { sign_in_as_a_valid_user(me) }

      context 'with valid attributes' do
        before do
          post "/api/v1/questions/#{question.id}/answers", answer: valid_attributes, question: question, format: :json
        end

        it 'returns 201 status' do
          expect(last_response.status).to eq 201
        end

        it 'saves valid answer' do
          expect do
            post "/api/v1/questions/#{question.id}/answers",
                 question: valid_attributes,
                 answer: valid_attributes,
                 format: :json
          end.to change(Answer, :count).by(1)
        end

        it 'contains body' do
          expect(last_response.body).to be_json_eql(valid_attributes[:body].to_json).at_path('body')
        end

        it_behaves_like 'action cable broadcast', AnswerSerializer, 'answer', 'create' do
          let(:request_for) do
            post "/api/v1/questions/#{question.id}/answers", answer: valid_attributes, question: question, format: :json
          end
          let(:channel) { "question/#{question.id}/answers" }
        end
      end

      context 'with invalid attributes' do
        before do
          sign_in_as_a_valid_user(me)
          post "/api/v1/questions/#{question.id}/answers", question: question, answer: invalid_attributes, format: :json
        end

        it 'returns 422 status' do
          expect(last_response.status).to eq 422
        end

        it 'does not save invalid answer' do
          expect do
            post "/api/v1/questions/#{question.id}/answers",
                 question: question,
                 answer: invalid_attributes,
                 format: :json
          end.not_to change(Answer, :count)
        end

        it 'contains errors' do
          expect(last_response.body).to have_json_path('errors')
        end
      end
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    let!(:answer) { create(:answer, user: me, question: question) }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :patch do
        let(:path) { "/api/v1/answers/#{answer.id}" }
      end
    end

    context 'when authorized' do
      before { sign_in_as_a_valid_user(me) }

      context 'when valid attributes' do
        before do
          patch "/api/v1/answers/#{answer.id}", format: :json, answer: valid_attributes
          answer.reload
        end

        it 'updates body' do
          expect(answer.body).to eq valid_attributes[:body]
        end

        it_behaves_like 'action cable broadcast', AnswerSerializer, 'answer', 'update' do
          let(:request_for) do
            patch "/api/v1/answers/#{answer.id}", format: :json, answer: valid_attributes
          end
          let(:channel) { "question/#{question.id}/answers" }
        end
      end
    end

    context 'when invalid attributes' do
      it 'does not update body' do
        old_body = answer.body
        patch "/api/v1/answers/#{answer.id}", format: :json, answer: invalid_attributes
        answer.reload
        expect(answer.body).to eq old_body
      end
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let!(:answer) { create(:answer, user: me) }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized_api', :delete do
        let(:path) { "/api/v1/answers/#{answer.id}" }
      end
    end

    context 'when authorized' do
      let!(:answer) { create(:answer, user: me, question: question) }

      before { sign_in_as_a_valid_user(me) }

      it 'deletes answer' do
        expect do
          delete "/api/v1/answers/#{answer.id}", format: :json
        end.to change(Answer, :count).by(-1)
      end

      it_behaves_like 'action cable broadcast', AnswerSerializer, 'answer', 'destroy' do
        let(:request_for) do
          delete "/api/v1/answers/#{answer.id}", format: :json
        end
        let(:channel) { "question/#{question.id}/answers" }
      end
    end
  end
end
