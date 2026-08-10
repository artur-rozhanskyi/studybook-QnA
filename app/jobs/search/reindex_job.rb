module Search
  class ReindexJob < ApplicationJob
    queue_as :default

    def perform(class_name, id, action = 'upsert')
      Search::Indexer.new(class_name: class_name, id: id, action: action).call
    end
  end
end
