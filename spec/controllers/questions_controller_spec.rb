RSpec.describe QuestionsController, type: :controller do
  let(:valid_session) { {} }
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:serializer) { object_double(QuestionSerializer, as_json: '') }

  describe 'GET #index' do
    before { get :index }

    let(:questions) { create_list(:question, 5) }

    it 'render index template' do
      expect(response).to render_template :index
    end

    it 'populates an array of all question' do
      expect(assigns(:questions)).to match_array questions
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it 'assigns requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'render show template' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before do
      sign_in_user(user)
      get :new
    end

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new Question
    end

    it 'render new template' do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    before do
      sign_in_user(user)
      get :edit, params: { id: question }
    end

    it 'assigns a requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'render edit template' do
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    before { sign_in_user(user) }

    context 'with valid attributes' do
      it 'save valid question' do
        expect do
          post :create, params: { question: attributes_for(:question) }
        end
          .to change(Question, :count).by(1)
      end

      it 'redirects to show view ' do
        post :create, params: { question: attributes_for(:question) }
        expect(response).to redirect_to question_path(assigns(:question_form))
      end

      it 'publishes new question to questions chanel' do
        allow(QuestionSerializer).to receive(:new).and_return(serializer)
        expect(ActionCable.server).to receive(:broadcast)
          .with('questions', { 'action' => 'create', 'question' => serializer }.as_json)
        post :create, params: { question: attributes_for(:question) }
      end
    end

    context 'with invalid attributes' do
      it 'not save invalid question' do
        expect do
          post :create, params: { question: attributes_for(:question_invalid) }
        end
          .not_to change(Question, :count)
      end

      it 're-render new template' do
        post :create, params: { question: attributes_for(:question_invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    before { sign_in_user(user) }

    let(:new_attributes) { { title: Faker::Lorem.question, body: Faker::Lorem.question } }

    describe 'belongs to current user' do
      context 'with valid attributes' do
        before { patch :update, params: { id: question, question: new_attributes } }

        it 'assigns a requested question to @question' do
          expect(assigns(:question)).to eq question
        end

        it 'changes question title' do
          question.reload
          expect(question.title).to eq new_attributes[:title]
        end

        it 'changes question body' do
          question.reload
          expect(question.body).to eq new_attributes[:body]
        end

        it 'redirect to the updated question' do
          expect(response).to redirect_to question
        end

        it 'publishes updated question to questions chanel' do
          allow(QuestionSerializer).to receive(:new).and_return(serializer)
          expect(ActionCable.server).to receive(:broadcast)
            .with('questions',
                  { 'action' => 'update', 'question' => serializer }.as_json)
          patch :update, params: { id: question, question: new_attributes }
        end
      end

      context 'with invalid attributes' do
        before do
          patch :update,
                params: { id: question, question: attributes_for(:question_invalid) }
        end

        it 'do not changes question' do
          reloaded_question = question.reload
          expect(reloaded_question).to eq question
        end

        it 'redirect to the updated question' do
          expect(response).to render_template :edit
        end
      end
    end

    describe 'not belongs to current user' do
      before do
        sign_in_user(create(:user))
        patch :update, params: { id: question, question: new_attributes }
        question.reload
      end

      it 'not changes question title' do
        expect(question.title).not_to eq new_attributes[:title]
      end

      it 'not changes question body' do
        expect(question.body).not_to eq new_attributes[:body]
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in_user(user)
      question
    end

    describe 'belongs to current user' do
      it 'deletes question' do
        expect do
          delete :destroy, params: { id: question }
        end
          .to change(Question, :count).by(-1)
      end

      it 'publishes updated question to questions chanel' do
        allow(QuestionSerializer).to receive(:new).and_return(serializer)
        expect(ActionCable.server).to receive(:broadcast)
          .with('questions',
                { 'action' => 'destroy', 'question' => serializer }.as_json)
        delete :destroy, params: { id: question }
      end
    end

    describe 'not belongs to current user' do
      it 'redirect to the index template' do
        sign_in_user(create(:user))
        expect do
          delete :destroy, params: { id: question }
        end
          .not_to change(Question, :count)
      end
    end
  end

  describe 'POST #subscribe' do
    before { sign_in_user(user) }

    it 'increases question subscribe' do
      expect do
        post :subscribe, params: { id: question, format: :json }
      end
        .to change(question.subscribed_users, :count).by(1)
    end
  end

  describe 'POST #unsubscribe' do
    before do
      question.subscribed_users << user
      sign_in_user(user)
    end

    it 'decreases question subscribe' do
      expect do
        post :unsubscribe, params: { id: question, format: :json }
      end
        .to change(question.subscribed_users, :count).by(-1)
    end
  end
end
