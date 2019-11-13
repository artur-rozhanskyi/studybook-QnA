RSpec.describe 'UserEditComments', type: :feature do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let!(:question) { create(:question, :with_comment, user: user) }
  let(:comment) { question.comments.first }
  let(:new_comment_body) { Faker::Lorem.sentence }

  describe 'Registered user edit comment', js: true do
    context 'when comment belong to user' do
      context 'when visit question page' do
        before do
          sign_in(user)
          visit question_path(question)
        end

        it 'has edit comment link' do
          within '.comment', match: :first do
            expect(page).to have_button 'Edit'
          end
        end

        context 'with valid attribute' do
          it 'has update comment' do
            edit_subject(new_comment_body, 'comment')
            find('.question')
            expect(comment.body).to eq new_comment_body
          end
        end

        context 'with invalid attribute' do
          let(:invalid_comment) { attributes_for(:invalid_comment) }

          it 'has not updated comment' do
            old_body = comment.body
            edit_subject(invalid_comment, 'comment')
            expect(comment.body).to eq old_body
          end
        end
      end

      context 'when multiple session' do
        let!(:old_body) { comment.body }

        before do
          Capybara.using_session 'another_user' do
            sign_in another_user, scope: :user
            visit question_path(question)
          end
          Capybara.using_session 'guest' do
            visit question_path(question)
          end
          Capybara.using_session 'user' do
            sign_in user, scope: :user
            visit question_path(question)
            edit_subject(new_comment_body, 'comment')
          end
        end

        it 'has not old comment body' do
          Capybara.using_session 'another_user' do
            expect(page).not_to have_content old_body
          end
          Capybara.using_session 'guest' do
            expect(page).not_to have_content old_body
          end
          Capybara.using_session 'user' do
            expect(page).not_to have_content old_body
          end
        end

        it 'has new comment body' do
          Capybara.using_session 'another_user' do
            expect(page).to have_content new_comment_body
          end
          Capybara.using_session 'guest' do
            expect(page).to have_content new_comment_body
          end
          Capybara.using_session 'user' do
            expect(page).to have_content new_comment_body
          end
        end
      end
    end

    context 'when comment not belong to user' do
      it 'has not comment link' do
        sign_in(create(:user))
        visit question_path(question)
        within '.comment', match: :first do
          expect(page).not_to have_button 'Edit'
        end
      end
    end
  end
end
