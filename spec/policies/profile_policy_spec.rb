describe ProfilePolicy do
  subject(:profile_policy) { described_class }

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:object) { create(:profile, user: user) }

  context 'when permissions update, edit' do
    permissions :update?, :edit? do
      it 'grants access if user is owner' do
        expect(profile_policy).to permit(user, object)
      end

      it 'denied access if user is not owner and user is an admin' do
        expect(profile_policy).not_to permit(admin, object)
      end

      it 'denied access if user is not owner and user is an guest' do
        expect(profile_policy).not_to permit(nil, object)
      end
    end
  end

  context 'when permissions index' do
    permissions :index? do
      it 'denied access if user is owner' do
        expect(profile_policy).not_to permit(user, object)
      end

      it 'grants denied access if user is an admin' do
        expect(profile_policy).to permit(admin, object)
      end

      it 'denied access if user is an guest' do
        expect(profile_policy).not_to permit(nil, object)
      end
    end
  end

  context 'when permissions show' do
    permissions :show? do
      it 'grants access if user is owner' do
        expect(profile_policy).to permit(user, object)
      end

      it 'grants denied access if user is not owner and user is an admin' do
        expect(profile_policy).to permit(admin, object)
      end

      it 'denied access if user is not owner and user is an guest' do
        expect(profile_policy).not_to permit(nil, object)
      end
    end
  end

  context 'when permissions new, create, destroy' do
    permissions :new?, :create?, :destroy? do
      it 'denied access if user is owner' do
        expect(profile_policy).not_to permit(user, object)
      end

      it 'denied denied access if user is not owner and user is an admin' do
        expect(profile_policy).not_to permit(admin, object)
      end

      it 'denied access if user is not owner and user is an guest' do
        expect(profile_policy).not_to permit(nil, object)
      end
    end
  end
end
