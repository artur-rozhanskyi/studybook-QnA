class BaseForm < SimpleDelegator
  include ActiveModel::Validations
  include ActiveModel::Serialization
  include ActiveModel::Conversion
  include Comparable

  DELETE_ATTACHMENT = '1'.freeze

  def initialize(object = nil)
    super(object || self.class.to_s.gsub(/Form/i, '').constantize.new)
  end

  def submit(new_attributes)
    assign_attributes(new_attributes.except(:attachments_attributes))
    if valid?
      save.tap do |save_result|
        save_attachments(new_attributes.delete(:attachments_attributes)) if save_result
      end
    else
      false
    end
  end

  private

  def save_attachments(attachments_attributes)
    return if attachments_attributes.blank?

    attachments_attributes.each_value do |attachment_param|
      if attachment_param['_destroy'] == DELETE_ATTACHMENT
        Attachment.find(attachment_param['id']).destroy
      elsif attachment_param['file'].present?
        Attachment.create(attachment_param.merge(attachmentable: __getobj__))
      end
    end
  end

  def model_name
    __getobj__.model_name
  end
end
