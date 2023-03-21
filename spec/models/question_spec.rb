RSpec.describe Question, type: :model do
  let(:question) { create(:question) }

  it 'is valid with valid attributes' do
    expect(build(:question)).to be_valid
  end

  it 'is invalid with invalid attributes' do
    expect(build(:question, title: nil, body: nil)).not_to be_valid
  end

  it { is_expected.to belong_to :user }

  it { is_expected.to have_many :attachments }

  it { is_expected.to have_and_belong_to_many(:subscribed_users).class_name('User') }

  it { is_expected.to belong_to(:best_answer).class_name('Answer').optional }

  it_behaves_like 'commentable'
end
