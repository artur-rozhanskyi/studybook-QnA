RSpec.describe 'UserSubscribeQuestion' do
  describe 'User Subscribe on question' do
    let(:user) { create(:user) }
    let(:question) { create(:question, user: user) }

    context 'when registered user', :js do
      before do
        sign_in(user)
        visit question_path(question)
      end

      it 'has button to subscribe' do
        expect(page).to have_button('Subscribe')
      end
    end

    context 'when multiply session', :js do
      it 'subscribes user to question' do
        Capybara.using_session 'user' do
          sign_in(user)
          visit question_path(question)
          click_on 'Subscribe'
          expect(page).to have_button('Unsubscribe')
        end

        Capybara.using_session 'another_user' do
          sign_in(create(:user))
          visit question_path(question)
          click_on 'Subscribe'
          expect(page).to have_button('Unsubscribe')
        end

        Capybara.using_session 'guest' do
          visit question_path(question)
          expect(page).to have_no_button 'Subscribe'
        end
      end
    end
  end
end
