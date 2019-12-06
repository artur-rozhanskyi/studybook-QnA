RSpec.describe UsersController, type: :controller do
  describe '#update' do
    let(:user) { create(:user) }
    let(:new_password) { { password: '123321', password_confirmation: '123321' } }

    before { sign_in(user) }

    it 'updates user password' do
      old_password = user.encrypted_password
      post :update, params: { id: user, user: new_password }
      user.reload
      expect(user.encrypted_password).not_to eq old_password
    end
  end
end
