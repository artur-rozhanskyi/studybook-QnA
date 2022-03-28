class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :body, :title, :attachments, :comments, :answers, :user_id

  has_many :answers
  has_many :comments
  has_many :attachments, serializer: AttachmentSerializer

  delegate :attachments, to: :object
end
