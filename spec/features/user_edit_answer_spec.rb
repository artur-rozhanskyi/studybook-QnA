RSpec.describe 'UserEditAnswers', type: :feature do
  describe 'User edit answer' do
    context 'with registered user' do
      let(:user) { create(:user) }
      let!(:answer) { create(:answer, question: create(:question), user: user) }
      let(:new_answer_body) { Faker::Lorem.sentence }

      before do
        sign_in(user)
        visit question_path(answer.question)
      end

      it 'has edit answer link' do
        within '.answers' do
          expect(page).to have_link 'Edit'
        end
      end

      it 'has update answer', js: true do
        edit_answer(new_answer_body)
        expect(page).to have_content(new_answer_body)
      end

      it 'has not old answer body', js: true do
        edit_answer(new_answer_body)
        expect(page).not_to have_content(answer.body)
      end
    end
  end
end
