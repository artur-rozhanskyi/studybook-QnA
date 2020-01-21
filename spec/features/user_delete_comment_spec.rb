RSpec.describe 'UserDeleteComments', type: :feature do
  describe 'User delete answer' do
    context 'when registered user', js: true do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }
      let(:question) { create(:question) }
      let!(:comment) { create(:comment, user: user, commentable: question) }

      context 'when visit question page' do
        before do
          sign_in user
          visit question_path(question)
        end

        it 'has "Delete" button' do
          within '.comment', match: :first do
            expect(page).to have_button 'Delete'
          end
        end

        it 'has delete comment from database ' do
          expect do
            delete_subject('comment')
            sleep 2
          end
            .to change(Comment, :count).by(-1)
        end
      end

      context 'when multuple session' do
        it 'has delete current comment from page' do
          Capybara.using_session 'user' do
            sign_in user, scope: :user
            visit question_path(question)
            delete_subject('comment')
            within '.question' do
              expect(page).not_to have_content comment.body
            end
          end

          Capybara.using_session 'another_user' do
            sign_in another_user, scope: :user
            visit question_path(question)
            within '.question' do
              expect(page).not_to have_content comment.body
            end
          end
          Capybara.using_session 'guest' do
            visit question_path(question)
            within '.question' do
              expect(page).not_to have_content comment.body
            end
          end
        end
      end
    end
  end
end
