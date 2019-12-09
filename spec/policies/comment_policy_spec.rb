describe CommentPolicy do
  it_behaves_like 'policies', described_class do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }
    let(:object) { create(:comment, :for_question, user: user) }
  end

  it_behaves_like 'policies', described_class do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }
    let(:object) { create(:comment, :for_answer, user: user) }
  end
end
