RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  it 'is valid with valid attributes' do
    expect(build(:user)).to be_valid
  end

  it 'is invalid with invalid attributes' do
    expect(build(:user, email: nil, password: nil)).not_to be_valid
  end

  it { is_expected.to have_many :questions }

  it { is_expected.to have_many :answers }

  it { is_expected.to have_many :comments }

  describe '.find_for_oauth' do
    let!(:user) { create(:user) }
    let(:auth_params) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456') }

    context 'when user has already authorization' do
      it 'returns the user' do
        user.authorizations.create(provider: 'facebook', uid: '123456')
        expect(described_class.find_for_oauth(auth_params)).to eq user
      end
    end

    context 'when user has not authorization' do
      context 'when user already exists' do
        let(:auth_params) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: { email: user.email }) }

        it 'does not create new user' do
          expect { described_class.find_for_oauth(auth_params) }.not_to change(described_class, :count)
        end

        it 'creates user authorization' do
          expect { described_class.find_for_oauth(auth_params) }.to change(user.authorizations, :count).by(1)
        end

        it 'creates authorization with provider and uid' do
          authorization = described_class.find_for_oauth(auth_params).authorizations.first

          expect(authorization.provider).to eq(auth_params.provider)
          expect(authorization.uid).to eq(auth_params.uid)
        end

        it 'returns user' do
          expect(described_class.find_for_oauth(auth_params)).to eq user
        end
      end

      context 'when user does not exist' do
        let(:auth_params) do
          OmniAuth::AuthHash.new(provider: 'facebook', uid: '123456', info: { email: 'user.email@email.com' })
        end

        it 'creates new user' do
          expect { described_class.find_for_oauth(auth_params) }.to change(described_class, :count).by(1)
        end

        it 'returns a new user' do
          expect(described_class.find_for_oauth(auth_params)).to be_a(described_class)
        end

        it 'fills user emal' do
          user = described_class.find_for_oauth(auth_params)
          expect(user.email).to eq auth_params.info[:email]
        end

        it 'creates authorization for user' do
          user = described_class.find_for_oauth(auth_params)
          expect(user.authorizations).not_to be_empty
        end

        it 'creates authorization with provider and uid' do
          authorization = described_class.find_for_oauth(auth_params).authorizations.first

          expect(authorization.provider).to eq(auth_params.provider)
          expect(authorization.uid).to eq(auth_params.uid)
        end
      end
    end
  end
end
