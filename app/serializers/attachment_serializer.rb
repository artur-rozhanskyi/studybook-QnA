class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :url, :filename, :content_type

  delegate :file, to: :object

  delegate :content_type, :url, to: :file

  def filename
    file.identifier
  end
end
