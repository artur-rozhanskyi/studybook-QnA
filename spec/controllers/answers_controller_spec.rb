RSpec.describe AnswersController do
  let(:user) { create(:user) }
  let!(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, user: user, question: question) }
  let(:valid_session) { {} }
  let(:valid_attributes) { attributes_for(:answer) }
  let(:fake_serializer) { object_double(AnswerSerializer, as_json: '') }

  describe 'POST #create' do
    before { sign_in_user(user) }

    context 'with valid attributes' do
      it 'saves valid answer' do
        expect do
          post :create, params: { question_id: question, answer: valid_attributes },
                        format: :json,
                        session: valid_session
        end
          .to change(question.answers, :count).by(1)
      end

      it_behaves_like 'action cable broadcast', AnswerSerializer, 'answer', 'create' do
        let(:request_for) do
          post :create, params: { question_id: question, answer: valid_attributes },
                        format: :json,
                        session: valid_session
        end
        let(:channel) { "question/#{question.id}/answers" }
      end
    end

    context 'with invalid attributes' do
      it 'does not save invalid answer' do
        expect do
          post :create, params: { question_id: question,
                                  answer: attributes_for(:invalid_answer) },
                        format: :json,
                        session: valid_session
        end
          .not_to change(Answer, :count)
      end

      it 'has not render template create' do
        post :create, params: { question_id: question, answer: valid_attributes },
                      format: :json,
                      session: valid_session
        expect(response).not_to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    before { sign_in_user(answer.user) }

    let(:new_attributes) { { body: Faker::Lorem.sentence } }

    describe 'belongs to current user' do
      context 'with valid attributes' do
        before do
          patch :update, params: { id: answer,
                                   question_id: answer.question.id,
                                   answer: new_attributes },
                         format: :json
        end

        it 'assigns a requested answer to @answer' do
          expect(assigns(:answer)).to eq answer
        end

        it 'changes answer body' do
          answer.reload
          expect(answer.body).to eq new_attributes[:body]
        end

        it_behaves_like 'action cable broadcast', AnswerSerializer, 'answer', 'update' do
          let(:request_for) do
            patch :update, params: { id: answer,
                                     question: answer.question,
                                     answer: new_attributes },
                           format: :json
          end
          let(:channel) { "question/#{question.id}/answers" }
        end
      end

      context 'with invalid attributes' do
        before do
          patch :update, params: { id: answer,
                                   question_id: answer.question.id,
                                   answer: attributes_for(:invalid_answer) },
                         format: :json
        end

        it 'does not change question' do
          reloaded_answer = answer.reload
          expect(reloaded_answer).to eq answer
        end
      end
    end

    describe 'does not belong to current user' do
      it "doesn't changes answer body" do
        sign_in_user(create(:user))
        patch :update, params: { id: answer, question_id: question.id, answer: new_attributes },
                       format: :json
        answer.reload
        expect(answer.body).not_to eq new_attributes[:body]
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in_user(answer.user) }

    context 'when belongs to current user' do
      it 'deletes answer' do
        expect do
          delete :destroy, params: { id: answer, question_id: answer.question.id }, format: :json
        end
          .to change(Answer, :count).by(-1)
      end

      it_behaves_like 'action cable broadcast', AnswerSerializer, 'answer', 'destroy' do
        let(:request_for) do
          delete :destroy, params: { id: answer, question_id: answer.question.id }, format: :json
        end
        let(:channel) { "question/#{question.id}/answers" }
      end
    end

    context 'when does not belong to current user' do
      it 'has not change answer count' do
        sign_in_user(create(:user))
        expect do
          delete :destroy, params: { id: answer, question_id: answer.question.id }, format: :json
        end
          .not_to change(Answer, :count)
      end
    end
  end

  describe 'POST #best' do
    context 'when question belongs to user' do
      before { sign_in_user(user) }

      it 'returns 201 status' do
        post :best, params: { id: answer, question_id: question, format: :json }
        expect(response).to have_http_status :created
      end

      it 'updates best answer' do
        post :best, params: { id: answer, question_id: question, format: :json }
        question.reload
        expect(question.best_answer).to eq answer
      end
    end

    context 'when question does not belong to user' do
      let(:another_user) { create(:user) }

      before { sign_in_user(another_user) }

      it 'returns 401 unauthorized status' do
        post :best, params: { id: answer, question_id: question, format: :json }
        expect(response).to have_http_status :unauthorized
      end

      it 'does not update best answer' do
        expect do
          post :best, params: { id: answer, question_id: question, format: :json }
        end.not_to change(question, :best_answer)
      end
    end
  end
end
