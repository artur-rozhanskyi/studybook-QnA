RSpec.describe 'UserEditComments', type: :feature do
  let(:user) { create(:user) }
  let!(:question) { create(:question, :with_comment, user: user) }
  let(:comment) { question.comments.first }
  let(:new_comment_body) { Faker::Lorem.sentence }

  describe 'Registered user edit comment', js: true do
    context 'when comment belong to user' do
      before do
        sign_in(user)
        visit question_path(question)
      end

      context 'with valid attribute' do
        it 'has edit comment link' do
          within '.comment', match: :first do
            expect(page).to have_button 'Edit'
          end
        end

        it 'has update comment' do
          edit_subject(new_comment_body, 'comment')
          find '.comments'
          expect(comment.body).to eq new_comment_body
        end

        it 'has not old comment body' do
          old_body = comment.body
          edit_subject(new_comment_body, 'comment')
          find '.comments'
          expect(page).not_to have_content old_body
        end

        it 'has new comment body' do
          edit_subject(new_comment_body, 'comment')
          find '.comments'
          expect(page).to have_content new_comment_body
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
