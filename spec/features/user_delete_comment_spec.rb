RSpec.describe 'UserDeleteComments', type: :feature do
  describe 'User delete answer' do
    context 'when registered user', js: true do
      let(:user) { create(:user) }
      let(:question) { create(:question) }
      let!(:comment) { create(:comment, user: user, commentable: question) }

      before do
        sign_in user
        visit question_path(question)
      end

      it 'has "Delete" button' do
        within '.comment', match: :first do
          expect(page).to have_button 'Delete'
        end
      end

      it 'has delete current comment from page' do
        delete_subject('comment')
        expect(page).not_to have_content comment.body
      end

      it 'has delete comment from database ' do
        expect do
          delete_subject('comment')
          find('.comments')
        end
          .to change(Comment, :count).by(-1)
      end
    end
  end
end
