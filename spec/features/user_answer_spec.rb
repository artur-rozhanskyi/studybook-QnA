RSpec.describe 'UserAnswers' do
  describe 'User create answer', :js do
    context 'with registered user' do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }
      let(:question) { create(:question) }
      let(:answer_body) { attributes_for(:answer)[:body] }

      context 'when user open question page' do
        before do
          sign_in(user)
          visit question_path(question)
        end

        it 'has answer form' do
          expect(page).to have_field 'Your answer'
        end

        it 'keeps path at current question path' do
          expect(page).to have_current_path(question_path(question))
        end
      end

      context 'when multiple sessions' do
        it 'has new answer body' do
          Capybara.using_session 'user' do
            sign_in user, scope: :user
            visit question_path(question)
            fill_in 'Your answer', with: answer_body
            click_on 'Answer'
            expect(page).to have_current_path(question_path(question))
            expect(page).to have_content(answer_body)
          end

          Capybara.using_session 'another_user' do
            sign_in another_user, scope: :user
            visit question_path(question)
            expect(page).to have_content(answer_body)
          end

          Capybara.using_session 'guest' do
            visit question_path(question)
            expect(page).to have_content(answer_body)
          end
        end
      end
    end

    context 'with non-registered user' do
      it 'has not answer form' do
        Capybara.using_session 'guest' do
          expect(page).to have_no_field 'Your answer'
        end
      end
    end
  end

  describe 'User create invalid answer', :js do
    context 'with registered user' do
      let(:user) { create(:user) }
      let(:invalid_answer) { build(:invalid_answer, question: create(:question)) }

      it 'has not answer form' do
        sign_in(user)
        visit question_path(invalid_answer.question)
        fill_in 'Your answer', with: invalid_answer.body
        click_on 'Answer'
        expect(page).to have_content 'Body can\'t be blank'
      end
    end
  end
end
