class Question < ApplicationRecord
  validates :title, :body, presence: true

  has_many :answers, dependent: :destroy
  belongs_to :user

  default_scope -> { order(:created_at) }
end
