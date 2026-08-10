module Search
  class Reindexer
    class Error < StandardError
    end

    def initialize(index_definition, client: Search.client, batch_size: 500)
      @index_definition = index_definition
      @client = client
      @batch_size = batch_size
    end

    def call
      return unless client.enabled?

      reindex!(
        next_index_name,
        current_index_name
      )
    rescue StandardError => e
      Search.logger.warn("Search reindex skipped for #{index_definition.key}: #{e.message}")
    end

    private

    attr_reader :index_definition, :client, :batch_size

    def reindex!(target_index_name, source_index_name)
      create_target_index(target_index_name)
      indexed_count = bulk_index(target_index_name)
      validate_target_index!(target_index_name, indexed_count)
      switch_alias(target_index_name, source_index_name)
      delete_source_index(source_index_name, target_index_name)
    end

    def next_index_name
      index_definition.next_versioned_index_name(client.raw_client)
    end

    def current_index_name
      index_definition.current_index_name(client.raw_client)
    end

    def create_target_index(index_name)
      client.create_index(index_definition, index_name)
    end

    def switch_alias(target_index_name, source_index_name)
      client.switch_alias(index_definition, target_index_name, old_index_name: source_index_name)
    end

    def delete_source_index(source_index_name, target_index_name)
      return if source_index_name.blank? || source_index_name == target_index_name

      client.delete_index(source_index_name)
    end

    def bulk_index(index_name)
      indexed_count = 0

      index_definition.model_class.find_in_batches(batch_size: batch_size) do |records|
        indexed_count += records.count
        response = client.bulk(body: bulk_body(index_name, records))
        raise Error, bulk_error_message(response) if bulk_failed?(response)
      end

      indexed_count
    end

    def bulk_body(index_name, records)
      records.flat_map { |record| bulk_item(index_name, record) }
    end

    def bulk_item(index_name, record)
      [
        {
          index: {
            _index: index_name,
            _id: record.id
          }
        },
        index_definition.document_for(record)
      ]
    end

    def bulk_failed?(response)
      response.fetch('errors', false) || bulk_item_errors?(response)
    end

    def validate_target_index!(index_name, expected_count)
      actual_count = client.raw_client.count(index: index_name).fetch('count')
      return if actual_count == expected_count

      raise Error, "Indexed #{actual_count} documents, expected #{expected_count}"
    end

    def bulk_item_errors?(response)
      response.fetch('items', []).any? do |item|
        item.fetch('index', {}).key?('error')
      end
    end

    def bulk_error_message(response)
      errors = response.fetch('items', []).filter_map { |item| item.fetch('index', {})['error'] }
      errors.empty? ? 'Bulk indexing failed' : "Bulk indexing failed: #{errors.first}"
    end
  end
end
