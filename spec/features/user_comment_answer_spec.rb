RSpec.describe 'UserCommentAnswers', type: :feature do
  let(:user) { create(:user) }
  let!(:answer) { create(:answer, question: create(:question), user: user) }
  let(:attributes) { attributes_for(:comment) }

  describe 'Registered user create comment a answer', js: true do
    before do
      sign_in(user)
      visit question_path(answer.question)
    end

    context 'with valid attribute' do
      it 'has "Add comment" button' do
        within '.answer .new_comment', match: :first do
          expect(page).to have_button('Add comment')
        end
      end

      it 'has comment form' do
        within '.answer .new_comment', match: :first do
          click_on 'Add comment'
          expect(page).to have_field 'comment[body]'
        end
      end

      it 'adds comment to answer' do
        within '.answer .new_comment', match: :first do
          expect do
            comment_record(attributes[:body])
            find('form')
          end
            .to change(Comment, :count).by(1)
        end
      end

      it 'adds comment body to answer comment list' do
        within '.answer' do
          comment_record(attributes[:body])
          expect(page).to have_content attributes[:body]
        end
      end
    end

    context 'with invalid attribute' do
      let(:invalid_comment) { attributes_for(:invalid_comment) }

      it 'has message with errors' do
        within '.answer .new_comment', match: :first do
          comment_record(invalid_comment[:body])
          expect(page).to have_content 'Body can\'t be blank'
        end
      end
    end
  end

  describe 'Non-registered user to create comment a answer', js: true do
    it 'has not "Add comment" button' do
      visit question_path(answer.question)
      within '.question' do
        expect(page).not_to have_button('Add comment')
      end
    end
  end
end
