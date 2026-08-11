module Search
  class Indexer
    def initialize(class_name:, id:, action: 'upsert')
      @class_name = class_name
      @id = id
      @action = action
    end

    def call
      index_definition = Search::Registry.for_class_name(class_name)
      return unless index_definition

      ensure_index(index_definition)
      delete_record(index_definition) || index_record(index_definition)
    rescue StandardError => e
      Search.logger.warn("Search indexing skipped for #{class_name}(#{id}): #{e.message}")
    end

    private

    attr_reader :class_name, :id, :action

    def ensure_index(index_definition)
      Search.client.ensure_index(index_definition)
    end

    def delete_record(index_definition)
      return unless action == 'delete'

      Search.client.delete(index_definition, id)
    end

    def index_record(index_definition)
      return if action == 'delete'

      record = index_definition.model_class.find_by(id: id)
      return unless record

      Search.client.index_document(index_definition, id, index_definition.document_for(record))
    end
  end
end
