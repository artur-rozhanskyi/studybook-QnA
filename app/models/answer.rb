class Answer < ApplicationRecord
  include ActiveModel::Serializers::JSON

  belongs_to :question
  belongs_to :user

  has_many :attachments, as: :attachmentable, autosave: true, dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true

  validates :body, presence: true

  default_scope -> { order(:created_at) }
end
