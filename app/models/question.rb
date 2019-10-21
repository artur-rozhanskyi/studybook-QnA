class Question < ApplicationRecord
  validates :title, :body, presence: true

  has_many :answers, dependent: :destroy
  has_many :attachments, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :attachments

  default_scope -> { order(:created_at) }
end
