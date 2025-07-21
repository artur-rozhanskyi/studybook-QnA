RSpec.describe Profile do
  let(:profile) { create(:profile) }

  it { is_expected.to belong_to :user }

  it { is_expected.to have_one :avatar_attachment }
end
