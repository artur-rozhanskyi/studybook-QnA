RSpec.describe Question, type: :model do
  let(:question) { create(:question) }

  it 'is valid with valid attributes' do
    expect(build(:question)).to be_valid
  end

  it 'is invalid with invalid attributes' do
    expect(build(:question, title: nil, body: nil)).not_to be_valid
  end
end
