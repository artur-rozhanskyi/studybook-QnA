namespace :search do
  desc 'Create or update OpenSearch indices'
  task setup: :environment do
    Search::Registry::INDEXES.each_value { |index_definition| Search.client.ensure_index(index_definition) }
  end

  desc 'Reindex all searchable records'
  task reindex: :environment do
    Search::BulkIndexer.new.call
  end
end
