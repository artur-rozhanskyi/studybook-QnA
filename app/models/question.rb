class Question < ApplicationRecord
  include Commentable

  validates :title, :body, presence: true

  has_many :answers, dependent: :destroy
  has_many :attachments, as: :attachmentable, dependent: :destroy
  belongs_to :user

  has_and_belongs_to_many :subscribed_users, class_name: 'User'

  default_scope -> { order(:created_at) }
end
