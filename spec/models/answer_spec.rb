require 'rails_helper'

RSpec.describe Answer, type: :model do
  let(:answer) { create(:answer) }

  it 'is valid with valid attributes' do
    expect(build(:answer)).to be_valid
  end

  it 'is invalid with invalid attributes' do
    expect(build(:answer, body: nil)).not_to be_valid
  end

  it { is_expected.to belong_to :user }
end
