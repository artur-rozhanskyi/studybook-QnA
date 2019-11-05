RSpec.describe 'UserDeleteAnswers', type: :feature do
  describe 'User delete answer' do
    context 'when registered user', js: true do
      let(:user) { create(:user) }
      let!(:answer) { create(:answer, user: user, question: create(:question)) }

      before do
        sign_in user
        visit question_path(answer.question)
      end

      it 'has link Delete answer' do
        expect(page).to have_link 'Delete'
      end

      it 'has delete current answer' do
        delete_subject('answer')
        expect(page).not_to have_content answer.body
      end

      it 'has not Edit link ' do
        delete_subject('answer')
        within '.answers' do
          expect(page).not_to have_link 'Edit'
        end
      end

      it 'has delete answer from database ' do
        expect do
          delete_subject('answer')
          find('.answers')
        end
          .to change(Answer, :count).from(1).to(0)
      end
    end
  end
end
