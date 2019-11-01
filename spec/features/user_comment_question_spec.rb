RSpec.describe 'UserCommentQuestions', type: :feature do
  let(:user) { create(:user) }
  let(:question) { create(:question) }
  let(:attributes) { attributes_for(:comment) }

  describe 'Registered user create comment a question', js: true do
    before do
      sign_in(user)
      visit question_path(question)
    end

    context 'with valid attribute' do
      it 'has "Add comment" button' do
        within '.question' do
          expect(page).to have_button('Add comment')
        end
      end

      it 'has comment form' do
        click_on 'Add comment'
        expect(page).to have_field 'Your answer'
      end

      it 'adds comment to question' do
        within '.question_comments' do
          expect do
            fill_in_comment(attributes[:body])
            find('.new_comment')
          end
            .to change(Comment, :count).by(1)
        end
      end

      it 'adds comment body to question comment list' do
        within '.question' do
          fill_in_comment(attributes[:body])
          expect(page).to have_content attributes[:body]
        end
      end
    end

    context 'with invalid attribute' do
      let(:invalid_comment) { attributes_for(:invalid_comment) }

      it 'has message with errors' do
        within '.question' do
          fill_in_comment(invalid_comment[:body])
          expect(page).to have_content 'Body can\'t be blank'
        end
      end
    end
  end

  describe 'Non-registered user to create comment a question', js: true do
    it 'has not "Add comment" button' do
      visit question_path(question)
      within '.question' do
        expect(page).not_to have_button('Add comment')
      end
    end
  end
end
