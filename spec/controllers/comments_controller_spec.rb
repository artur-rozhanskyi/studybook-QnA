RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in_user(user) }

  context 'when add comment to question' do
    it_behaves_like 'nested comments controller' do
      let(:comment_user) { user }
      let(:commentable) { create(:question, user: user) }
      let(:valid_session) { {} }
    end
  end

  context 'when add comment to answer' do
    it_behaves_like 'nested comments controller' do
      let(:comment_user) { user }
      let(:commentable) { create(:answer, user: user) }
      let(:valid_session) { {} }
    end
  end
end
