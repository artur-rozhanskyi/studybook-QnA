RSpec.describe 'UserEditProfile', type: :feature do
  let(:profile) { create(:profile) }

  describe 'Registered user edit profiles' do
    before do
      sign_in profile.user
      visit edit_user_profile_path profile.user
    end

    it 'has field first name' do
      expect(page).to have_field 'First name'
    end

    it 'has field last name' do
      expect(page).to have_field 'Last name'
    end

    it 'has field avatar' do
      expect(page).to have_field 'Avatar'
    end

    context 'with valid attribute' do
      let(:new_profile) { attributes_for(:profile) }
      let(:avatar) { Rack::Test::UploadedFile.new(Rails.root + 'spec/fixtures/images/example.png', 'image/png') }

      before { update_profile(new_profile.merge(avatar: avatar)) }

      it 'has new first name' do
        expect(page).to have_content new_profile[:first_name]
      end

      it 'has new last name' do
        expect(page).to have_content new_profile[:last_name]
      end

      it 'has avatar' do
        expect(page).to have_css("img[src*='example']")
      end
    end
  end

  describe 'Non-registered user edit profiles' do
    it 'has not permission' do
      visit edit_user_profile_path(profile.user)
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
    end
  end
end
