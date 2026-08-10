module Search
  class Query
    def initialize(text:, search_in:)
      @text = text.to_s.strip
      @search_in = search_in.to_s
    end

    def call
      return {} if text.blank? || search_in.blank?

      Search::Registry.for(search_in).each_with_object({}) do |index_definition, results|
        records = records_for(index_definition)
        next if records.blank?

        results[index_definition.key] = records
      end
    end

    private

    attr_reader :text, :search_in

    def records_for(index_definition)
      if Search.client.enabled?
        ids = Search.client.search(index_definition, text)
        return index_definition.hydrate(ids)
      end

      index_definition.database_scope(text).to_a
    rescue StandardError => e
      Search.logger.warn("Search query fallback for #{index_definition.key}: #{e.message}")
      index_definition.database_scope(text).to_a
    end
  end
end
