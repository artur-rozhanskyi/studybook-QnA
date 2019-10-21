class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user

  has_many :attachments, as: :attachmentable, dependent: :destroy

  validates :body, presence: true

  default_scope -> { order(:created_at) }
end
