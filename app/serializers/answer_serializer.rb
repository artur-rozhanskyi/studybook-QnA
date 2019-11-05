class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :body, :question_id, :user_id, :attachments

  has_many :attachments, serializer: AttachmentSerializer

  delegate :attachments, to: :object
end
