describe AnswerPolicy do
  it_behaves_like 'policies', described_class do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }
    let(:object) { create(:answer, user: user) }
  end
end
