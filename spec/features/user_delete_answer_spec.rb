RSpec.describe 'UserDeleteAnswers', type: :feature do
  describe 'User delete answer' do
    context 'when registered user', js: true do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }
      let(:answer) { create(:answer, user: user, question: create(:question)) }

      context 'when visit question page' do
        before do
          sign_in user
          visit question_path(answer.question)
        end

        it 'has link Delete answer' do
          expect(page).to have_link 'Delete'
        end

        it 'has delete answer from database ' do
          expect do
            delete_subject('answer')
            find('.question')
          end
            .to change(Answer, :count).by(-1)
        end
      end

      context 'when multiple session' do
        before do
          Capybara.using_session 'another_user' do
            sign_in another_user, scope: :user
            visit question_path(answer.question)
          end
          Capybara.using_session 'guest' do
            visit question_path(answer.question)
          end
          Capybara.using_session 'user' do
            sign_in user, scope: :user
            visit question_path(answer.question)
            delete_subject('answer')
          end
        end

        it 'has delete current answer' do
          Capybara.using_session 'another_user' do
            expect(page).not_to have_content answer.body
          end
          Capybara.using_session 'guest' do
            expect(page).not_to have_content answer.body
          end
          Capybara.using_session 'user' do
            expect(page).not_to have_content answer.body
          end
        end

        it 'has not Edit link ' do
          Capybara.using_session 'another_user' do
            expect(page).not_to have_link 'Edit'
          end
          Capybara.using_session 'guest' do
            expect(page).not_to have_link 'Edit'
          end
          Capybara.using_session 'user' do
            expect(page).not_to have_link 'Edit'
          end
        end
      end
    end
  end
end
