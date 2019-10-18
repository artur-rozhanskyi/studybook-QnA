RSpec.describe 'EditQuestions', type: :feature do
  describe 'User edits question' do
    let(:user) { create(:user) }
    let!(:question) { create(:question) }
    let(:new_attribute) { build(:question) }

    context 'when registered user' do
      before do
        sign_in(user)
        visit question_path(question)
        click_on 'Edit'
      end

      it 'has button to create question' do
        expect(page).to have_content('Edit Question')
      end

      it 'shows edit field with question title ' do
        expect(page).to have_field 'Title', with: question.title
      end

      it 'shows edit field with question body' do
        expect(page).to have_field 'Body', with: question.body
      end

      it 'update question title' do
        fill_in_question(new_attribute)
        expect(page).to have_content new_attribute.title
      end

      it 'update question body' do
        fill_in_question(new_attribute)
        expect(page).to have_content new_attribute.body
      end
    end

    context 'when non-registered user' do
      it 'has not button to create question' do
        visit edit_question_path(question)
        expect(page).to have_content 'You need to sign in or sign up before continuing.'
      end
    end
  end
end
