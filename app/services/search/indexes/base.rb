module Search
  module Indexes
    class Base
      extend SchemaFields
      extend IndexLifecycle

      class << self
        def key
          name.demodulize.delete_suffix('Index').underscore
        end

        def index_name
          alias_name
        end

        def alias_name
          "#{Search.configuration.index_prefix}-#{key}"
        end

        def versioned_index_name(version)
          "#{alias_name}_v#{version}"
        end

        def definition
          {
            settings: settings,
            mappings: {
              properties: properties
            }
          }
        end

        def settings
          {
            analysis: {
              normalizer: normalizer_settings,
              analyzer: analyzer_settings
            }
          }
        end

        def search_request(text, size:)
          { size: size, query: multi_match_query(text) }
        end

        def searchable_fields
          raise NotImplementedError
        end

        def properties
          raise NotImplementedError
        end

        def model_class
          raise NotImplementedError
        end

        def document_for(_record)
          raise NotImplementedError
        end

        def database_scope(text)
          raise NotImplementedError
        end

        def hydrate(ids)
          return [] if ids.blank?

          records = model_class.where(id: ids).index_by(&:id)
          ids.filter_map { |id| records[id] }
        end

        def all_records
          model_class.find_each
        end

        def sanitize_query(text)
          "%#{model_class.sanitize_sql_like(text)}%"
        end

        private

        def normalizer_settings
          {
            lowercase_normalizer: {
              type: 'custom',
              filter: %w[lowercase asciifolding]
            }
          }
        end

        def analyzer_settings
          {
            search_text: {
              type: 'custom',
              tokenizer: 'standard',
              filter: %w[lowercase asciifolding]
            }
          }
        end

        def multi_match_query(text)
          {
            multi_match: {
              query: text,
              fields: searchable_fields,
              type: 'best_fields',
              operator: 'and',
              fuzziness: 'AUTO'
            }
          }
        end
      end
    end
  end
end
