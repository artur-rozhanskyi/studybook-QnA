module Searchable
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_search_upsert, on: [:create, :update]
    after_commit :enqueue_search_delete, on: :destroy
  end

  private

  def enqueue_search_upsert
    Search::ReindexJob.perform_later(self.class.name, id, 'upsert')
  end

  def enqueue_search_delete
    Search::ReindexJob.perform_later(self.class.name, id, 'delete')
  end
end
