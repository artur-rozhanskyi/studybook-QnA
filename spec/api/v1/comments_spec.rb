RSpec.describe 'Comments API', type: :api do
  let(:me) { create(:user) }

  context 'when add comment to question' do
    it_behaves_like 'nested comments api controller' do
      let(:comment_user) { me }
      let(:commentable) { create(:question, user: me) }
    end
  end

  context 'when add comment to answer' do
    it_behaves_like 'nested comments api controller' do
      let(:comment_user) { me }
      let(:commentable) { create(:answer, user: me) }
    end
  end
end
