RSpec.describe 'UserViewProfile' do
  let(:profile) { create(:profile) }
  let(:another_profile) { create(:profile) }

  describe 'Registered user view profiles' do
    before { sign_in profile.user }

    context 'when user is profiles owner' do
      before { visit user_profile_path profile.user }

      it 'shows user first name' do
        expect(page).to have_content profile.first_name
      end

      it 'shows user last name' do
        expect(page).to have_content profile.last_name
      end

      it 'shows user email' do
        expect(page).to have_content profile.user.email
      end

      it 'has link "Edit"' do
        expect(page).to have_link 'Edit'
      end
    end

    context 'when user is not profiles owner' do
      before { visit user_profile_path another_profile.user }

      it 'shows user first name' do
        expect(page).to have_content another_profile.first_name
      end

      it 'shows user last name' do
        expect(page).to have_content another_profile.last_name
      end

      it 'shows user email' do
        expect(page).to have_content another_profile.user.email
      end

      it 'has not link "Edit"' do
        expect(page).to have_no_link 'Edit'
      end
    end
  end

  describe 'Non-registered user view profiles' do
    it 'has not permission' do
      visit user_profile_path profile.user
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end
  end
end
