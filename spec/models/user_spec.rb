RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  it 'is valid with valid attributes' do
    expect(build(:user)).to be_valid
  end

  it 'is invalid with invalid attributes' do
    expect(build(:user, email: nil, password: nil)).not_to be_valid
  end

  it { is_expected.to have_many :questions }
end
