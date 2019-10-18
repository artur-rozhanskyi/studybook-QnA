RSpec.describe 'UserAnswers', type: :feature do
  describe 'User create answer', js: true do
    context 'with registered user' do
      let(:user) { create(:user) }
      let(:answer) { build(:answer, question: create(:question)) }

      before do
        sign_in(user)
        visit question_path(answer.question)
      end

      it 'has answer form' do
        expect(page).to have_field 'Your answer'
      end

      it 'adds answer to question' do
        fill_in 'Your answer', with: answer.body
        click_on 'Answer'
        expect(page).to have_content(answer.body)
      end

      it 'keeps path at current question path' do
        expect(page).to have_current_path(question_path(answer.question))
      end
    end

    context 'with non-registered user' do
      it 'has not answer form' do
        expect(page).not_to have_field 'Your answer'
      end
    end
  end

  describe 'User create invalid answer', js: true do
    context 'with registered user' do
      let(:user) { create(:user) }
      let(:invalid_answer) { build(:invalid_answer, question: create(:question)) }

      before do
        sign_in(user)
        visit question_path(invalid_answer.question)
      end

      it 'has not answer form' do
        fill_in 'Your answer', with: invalid_answer.body
        click_on 'Answer'
        expect(page).to have_content 'Body can\'t be blank'
      end
    end
  end
end
