RSpec.describe 'UserEditAnswers', type: :feature do
  describe 'User edit answer' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let!(:answer) { create(:answer, question: create(:question), user: user) }
    let(:new_answer_body) { Faker::Lorem.sentence }

    context 'when user open question page' do
      before do
        sign_in user
        visit question_path(answer.question)
      end

      it 'has "Edit" answer link' do
        within '.answers' do
          expect(page).to have_link 'Edit'
        end
      end
    end

    context 'with multiple session', js: true do
      before do
        Capybara.using_session 'another_user' do
          sign_in another_user
          visit question_path answer.question
        end

        Capybara.using_session 'guest' do
          visit question_path answer.question
        end

        Capybara.using_session 'user' do
          sign_in user
          visit question_path answer.question
          edit_subject new_answer_body, 'answer'
        end
      end

      it 'has update answer' do
        Capybara.using_session 'user' do
          expect(page).to have_content new_answer_body
        end

        Capybara.using_session 'another_user' do
          expect(page).to have_content new_answer_body
        end

        Capybara.using_session 'guest' do
          expect(page).to have_content new_answer_body
        end
      end

      it 'has not old answer body' do
        Capybara.using_session 'user' do
          expect(page).not_to have_content(answer.body)
        end

        Capybara.using_session 'another_user' do
          expect(page).not_to have_content(answer.body)
        end

        Capybara.using_session 'guest' do
          expect(page).not_to have_content(answer.body)
        end
      end
    end
  end
end
