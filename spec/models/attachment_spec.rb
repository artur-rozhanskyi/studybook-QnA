RSpec.describe Attachment, type: :model do
  it { is_expected.to belong_to :attachmentable }
end
