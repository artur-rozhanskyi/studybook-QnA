RSpec.describe ProfilesController, type: :controller do
  let(:profile) { create(:profile) }

  describe 'PATCH #update' do
    before { sign_in_user(profile.user) }

    let(:new_attributes) { attributes_for(:profile) }

    context 'when belongs to current user' do
      before do
        patch :update, params: { user_id: profile.user, profile: new_attributes }
        profile.reload
      end

      it 'changes profile first name' do
        expect(profile.first_name).to eq new_attributes[:first_name]
      end

      it 'changes profile last name' do
        expect(profile.last_name).to eq new_attributes[:last_name]
      end
    end

    context 'when does not belongs to current user' do
      before do
        sign_in_user(create(:user))
        patch :update, params: { user_id: profile.user, profile: new_attributes }
        profile.reload
      end

      it 'does not change profile first name' do
        expect(profile.first_name).not_to eq new_attributes[:first_name]
      end

      it 'does not change profile last name' do
        expect(profile.first_name).not_to eq new_attributes[:last_name]
      end
    end
  end
end
