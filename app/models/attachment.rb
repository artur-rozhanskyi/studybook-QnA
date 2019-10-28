class Attachment < ApplicationRecord
  belongs_to :attachmentable, polymorphic: true

  delegate :identifier, to: :file

  mount_uploader :file, FileUploader
end
