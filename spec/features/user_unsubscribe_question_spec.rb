RSpec.describe 'UserUnsubscribeQuestion' do
  describe 'User unsubscribe from question' do
    let(:user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:another_user) { create(:user) }

    before { question.subscribed_users << [user, another_user] }

    context 'when registered user', :js do
      before do
        sign_in(user)
        visit question_path(question)
      end

      it 'has button to unsubscribe' do
        expect(page).to have_button('Unsubscribe')
      end
    end

    context 'when multiply session', :js do
      it 'subscribes user to question' do
        Capybara.using_session 'user' do
          sign_in(user)
          visit question_path(question)
          click_on 'Unsubscribe'
          expect(page).to have_button('Subscribe')
        end

        Capybara.using_session 'another_user' do
          sign_in(another_user)
          visit question_path(question)
          click_on 'Unsubscribe'
          expect(page).to have_button('Subscribe')
        end

        Capybara.using_session 'guest' do
          visit question_path(question)
          expect(page).to have_no_button 'Unsubscribe'
        end
      end
    end
  end
end
