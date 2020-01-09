class Comment < ApplicationRecord
  after_save ThinkingSphinx::RealTime.callback_for(:comment)

  belongs_to :commentable, polymorphic: true

  belongs_to :user

  validates :body, presence: true
end
