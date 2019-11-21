class Question < ApplicationRecord
  include Commentable

  validates :title, :body, presence: true

  has_many :answers, dependent: :destroy
  has_many :attachments, as: :attachmentable, dependent: :destroy
  belongs_to :user

  default_scope -> { order(:created_at) }
end
