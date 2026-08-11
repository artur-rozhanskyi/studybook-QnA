module Search
  class BulkIndexer
    def call
      Search::Registry::INDEXES.each_value do |index_definition|
        Search::Reindexer.new(index_definition).call
      end
    rescue StandardError => e
      Search.logger.warn("Search bulk indexing skipped: #{e.message}")
    end
  end
end
