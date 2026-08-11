class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar

  after_commit :enqueue_user_reindex, on: [:create, :update, :destroy]

  private

  def enqueue_user_reindex
    Search::ReindexJob.perform_later('User', user_id, 'upsert')
  end
end
