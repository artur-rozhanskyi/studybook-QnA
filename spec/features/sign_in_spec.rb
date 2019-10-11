RSpec.describe 'SignIns', type: :feature do
  describe 'User sign in' do
    context 'when registered user try to login' do
      let(:user) { create(:user) }

      before do
        visit new_user_session_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Log in'
      end

      it 'log in succusesfull' do
        expect(page).to have_content 'Signed in successfully'
      end

      it 'have a possibility to log out' do
        expect(page).to have_content 'Log out'
      end
    end

    context 'when non-registered user try to login' do
      before do
        visit new_user_session_path
        fill_in 'Email', with: 'wrong@example.com'
        fill_in 'Password', with: '12345678'
        click_button 'Log in'
      end

      it 'show error message' do
        expect(page).to have_content(/Invalid email or password/i)
      end
    end
  end
end
