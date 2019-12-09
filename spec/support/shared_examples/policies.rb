RSpec.shared_examples_for 'policies' do |klass|
  subject { klass }

  permissions :update?, :edit? do
    it 'grants access if user is owner' do
      expect(subject).to permit(user, object)
    end

    it 'denied access if user is not owner and user is an admin' do
      expect(subject).not_to permit(admin, object)
    end

    it 'denied access if user is not owner and user is an guest' do
      expect(subject).not_to permit(nil, object)
    end
  end

  permissions :index?, :show? do
    it 'grants access if user is owner' do
      expect(subject).to permit(user, object)
    end

    it 'grants denied access if user is not owner and user is an admin' do
      expect(subject).to permit(admin, object)
    end

    it 'grants access if user is not owner and user is an guest' do
      expect(subject).to permit(nil, object)
    end
  end

  permissions :new?, :create?, :destroy? do
    it 'grants access if user is owner' do
      expect(subject).to permit(user, object)
    end

    it 'grants denied access if user is not owner and user is an admin' do
      expect(subject).to permit(admin, object)
    end

    it 'grants access if user is not owner and user is an guest' do
      expect(subject).not_to permit(nil, object)
    end
  end
end
