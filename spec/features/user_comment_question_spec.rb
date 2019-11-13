RSpec.describe 'UserCommentQuestions', type: :feature do
  let(:user) { create(:user) }
  let(:another_user) { create(:user) }
  let(:question) { create(:question) }
  let(:attributes) { attributes_for(:comment) }

  describe 'Registered user create comment a question', js: true do
    context 'when visit question path' do
      before do
        sign_in user
        visit question_path(question)
      end

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
            find('p')
          end
            .to change(Comment, :count).by(1)
        end
      end
    end

    context 'with valid attribute' do
      context 'with multiple session' do
        it 'adds comment body to question comment list' do
          Capybara.using_session 'user' do
            sign_in user
            visit question_path question
            fill_in_comment attributes[:body]
            within '.question' do
              expect(page).to have_content attributes[:body]
            end
          end

          Capybara.using_session 'another_user' do
            sign_in another_user
            visit question_path question
            within '.question' do
              expect(page).to have_content attributes[:body]
            end
          end

          Capybara.using_session 'guest' do
            visit question_path question
            within '.question' do
              expect(page).to have_content attributes[:body]
            end
          end
        end
      end
    end

    context 'with invalid attribute' do
      let(:invalid_comment) { attributes_for(:invalid_comment) }

      it 'has message with errors' do
        sign_in user
        visit question_path(question)
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
