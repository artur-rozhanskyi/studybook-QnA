class Answer < ApplicationRecord
  include Commentable

  belongs_to :question, touch: true
  belongs_to :user

  has_many :attachments, as: :attachmentable, dependent: :destroy

  validates :body, presence: true

  default_scope -> { order(:created_at) }

  def error_messages
    errors.full_messages
  end
end
