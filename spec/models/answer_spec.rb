RSpec.describe Answer do
  let(:answer) { create(:answer) }

  it 'is valid with valid attributes' do
    expect(build(:answer)).to be_valid
  end

  it 'is invalid with invalid attributes' do
    expect(build(:answer, body: nil)).not_to be_valid
  end

  it { is_expected.to belong_to :user }

  it { is_expected.to have_many :attachments }

  it_behaves_like 'commentable'
end
