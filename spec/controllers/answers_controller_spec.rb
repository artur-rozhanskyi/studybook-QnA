RSpec.describe AnswersController, type: :controller do
  let(:question) { create(:question) }
  let(:valid_session) { {} }

  describe 'POST #create' do
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
          post :create, params: { question_id: question, answer: attributes_for(:invalid_answer) },
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
end
