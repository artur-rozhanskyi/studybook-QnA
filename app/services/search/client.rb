require 'opensearch'

module Search
  class Client
    class Error < StandardError
    end

    class << self
      def instance
        @instance ||= new
      end
    end

    attr_reader :configuration, :raw_client

    def initialize(configuration: Search.configuration, raw_client: nil)
      @configuration = configuration
      @raw_client = raw_client || (configuration.enabled? ? build_client : nil)
    end

    delegate :enabled?, to: :configuration

    def ensure_index(index_definition)
      return unless enabled?

      index_definition.ensure_index!(raw_client)
    end

    def current_index_name(index_definition)
      return unless enabled?

      index_definition.current_index_name(raw_client)
    end

    def next_versioned_index_name(index_definition)
      return unless enabled?

      index_definition.next_versioned_index_name(raw_client)
    end

    def create_index(index_definition, index_name)
      return unless enabled?

      raw_client.indices.create(index: index_name, body: index_definition.definition)
    end

    def switch_alias(index_definition, new_index_name, old_index_name: nil)
      return unless enabled?

      index_definition.switch_alias!(raw_client, new_index_name, old_index_name: old_index_name)
    end

    def delete_index(index_name)
      return unless enabled?

      raw_client.indices.delete(index: index_name)
    rescue StandardError
      nil
    end

    def bulk(body:)
      return { 'errors' => false, 'items' => [] } unless enabled?

      raw_client.bulk(body: body)
    end

    def index_document(index_definition, record_id, document)
      return unless enabled?

      raw_client.index(
        index: index_definition.index_name,
        id: record_id,
        body: document,
        refresh: false
      )
    end

    def delete(index_definition, record_id)
      return unless enabled?

      raw_client.delete(
        index: index_definition.index_name,
        id: record_id,
        ignore: 404
      )
    end

    def search(index_definition, text, size: 100)
      return [] unless enabled?

      response = raw_client.search(
        index: index_definition.index_name,
        body: index_definition.search_request(text, size: size)
      )

      response.fetch('hits', {}).fetch('hits', []).map { |hit| hit.fetch('_id').to_i }
    end

    private

    def build_client
      OpenSearch::Client.new(configuration.client_options)
    end
  end
end
