RSpec.describe 'UserUpdatePassword', type: :feature do
  describe 'Registed user update password' do
    let(:profile) { create(:profile) }
    let(:new_password) { { password: '123321', password_confirmation: '123321' } }
    let(:wrong_password) { { password: '', password_confirmation: '' } }

    before do
      sign_in profile.user
      visit edit_user_profile_path(profile.user)
    end

    context 'with valid password' do
      it 'has flash successful notice' do
        update_password new_password
        expect(page).to have_content 'Password was successfully updated'
      end
    end

    context 'with invalid password' do
      it 'has flash failure notice' do
        update_password wrong_password
        expect(page).to have_content 'Password was not updated'
      end
    end
  end
end
