RSpec.describe AnswersController, type: :controller do
  let!(:question) { create(:question) }
  let(:user) { create(:user) }
  let(:answer) { create(:answer, user: user, question: question) }
  let(:valid_session) { {} }

  describe 'POST #create' do
    before { sign_in_user(user) }

    context 'with valid attributes' do
      it 'saves valid answer' do
        expect do
          post :create, params: { question_id: question, answer: attributes_for(:answer) },
                        format: :js,
                        session: valid_session
        end
          .to change(question.answers, :count).by(1)
      end

      it 'render template create' do
        post :create, params: { question_id: question, answer: attributes_for(:answer) },
                      format: :js,
                      session: valid_session
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      it 'does not save invalid answer' do
        expect do
          post :create, params: { question_id: question,
                                  answer: attributes_for(:invalid_answer) },
                        format: :js,
                        session: valid_session
        end
          .not_to change(Answer, :count)
      end

      it 'render template create' do
        post :create, params: { question_id: question, answer: attributes_for(:invalid_answer) },
                      format: :js,
                      session: valid_session
        expect(response).to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    before { sign_in_user(answer.user) }

    let(:new_attributes) { { body: Faker::Lorem.sentence } }

    # rubocop:disable RSpec/NestedGroups
    describe 'belongs to current user' do
      context 'with valid attributes' do
        before do
          patch :update, params: { id: answer,
                                   question_id: answer.question.id,
                                   answer: new_attributes },
                         format: :js
        end

        it 'assigns a requested question to @question' do
          expect(assigns(:answer)).to eq answer
        end

        it 'changes question body' do
          answer.reload
          expect(answer.body).to eq new_attributes[:body]
        end
      end

      context 'with invalid attributes' do
        before do
          patch :update, params: { id: answer,
                                   question_id: answer.question.id,
                                   answer: attributes_for(:invalid_answer) },
                         format: :js
        end

        it 'do not changes question' do
          reloaded_answer = answer.reload
          expect(reloaded_answer).to eq answer
        end
      end
    end

    describe 'not belongs to current user' do
      it 'not changes question body' do
        sign_in_user(create(:user))
        patch :update, params: { id: answer, question_id: question.id, answer: new_attributes },
                       format: :js
        answer.reload
        expect(answer.body).not_to eq new_attributes[:body]
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups

  describe 'DELETE #destroy' do
    before do
      sign_in_user(answer.user)
    end

    describe 'belongs to current user' do
      it 'deletes question' do
        expect do
          delete :destroy, params: { id: answer, question_id: answer.question.id }, format: :js
        end
          .to change(Answer, :count).by(-1)
      end

      it 'redirect to the delete template' do
        delete :destroy, params: { id: answer, question_id: answer.question.id }, format: :js
        expect(response).to render_template :destroy
      end
    end

    describe 'not belongs to current user' do
      it 'has not change answer count' do
        sign_in_user(create(:user))
        expect do
          delete :destroy, params: { id: answer, question_id: answer.question.id }, format: :js
        end
          .not_to change(Answer, :count)
      end
    end
  end
end
