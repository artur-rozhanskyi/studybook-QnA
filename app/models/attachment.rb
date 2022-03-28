class Attachment < ApplicationRecord
  belongs_to :attachmentable, polymorphic: true

  delegate :identifier, to: :file

  mount_uploader :file, FileUploader
  mount_base64_uploader :file, FileUploader, file_name: ->(_) { secure_token(10) }

  def self.secure_token(length = 16)
    SecureRandom.hex(length / 2)
  end
end
