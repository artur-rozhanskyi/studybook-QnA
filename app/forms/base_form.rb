class BaseForm
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Conversion

  attr_accessor :body, :attachments_attributes

  delegate :id, :attachments, :comments, :user, :model_name, :persisted?, to: :object

  DELETE_ATTACHMENT = '1'.freeze

  def initialize(object = nil)
    @object = object
  end

  def submit(attributes)
    self.attachments_attributes = attributes.delete(:attachments_attributes)
    self.body = attributes[:body]
    if valid?
      object.assign_attributes(attributes)
      object.save.tap do |save_result|
        save_attachments if attachments_attributes.present? && save_result
      end
    else
      false
    end
  end

  private

  def save_attachments
    attachments_attributes.values.each do |attachment_param|
      if attachment_param['_destroy'] == DELETE_ATTACHMENT
        Attachment.find(attachment_param['id']).destroy
      elsif attachment_param['file'].present?
        Attachment.create(attachment_param.merge(attachmentable: object))
      end
    end
  end
end
