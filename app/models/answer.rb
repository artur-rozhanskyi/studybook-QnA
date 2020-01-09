class Answer < ApplicationRecord
  after_save ThinkingSphinx::RealTime.callback_for(:answer)

  include Commentable

  belongs_to :question
  belongs_to :user

  has_many :attachments, as: :attachmentable, dependent: :destroy

  validates :body, presence: true

  default_scope -> { order(:created_at) }

  def error_messages
    errors.full_messages
  end
end
