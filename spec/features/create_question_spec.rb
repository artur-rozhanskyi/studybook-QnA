RSpec.describe 'CreateQuestions' do
  describe 'User creates question' do
    let(:user) { create(:user) }
    let(:question) { create(:question, user: user) }

    context 'when registered user' do
      before do
        visit questions_path
        sign_in(user)
        click_on 'Ask question'
      end

      it 'has button to create question' do
        expect(page).to have_content('New Question')
      end

      it 'has field title' do
        expect(page).to have_field('Title')
      end

      it 'has field body' do
        expect(page).to have_field('Body')
      end

      it 'shows asked question title' do
        ask_question(question)
        expect(page).to have_content question.title
      end

      it 'shows asked question body' do
        ask_question(question)
        expect(page).to have_content question.body
      end
    end

    context 'when non-registered user' do
      it 'has not button to create question' do
        visit questions_path
        expect(page).to have_no_content('Create question')
      end
    end
  end
end
