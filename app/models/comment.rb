class Comment < ApplicationRecord
  include Searchable

  belongs_to :commentable, polymorphic: true, touch: true

  belongs_to :user

  validates :body, presence: true
end
