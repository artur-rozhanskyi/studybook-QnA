module Search
  module Indexes
    module SchemaFields
      private

      def id_field
        { type: 'long' }
      end

      def long_field
        { type: 'long' }
      end

      def date_field
        { type: 'date' }
      end

      def keyword_field
        { type: 'keyword', normalizer: 'lowercase_normalizer' }
      end

      def text_field(analyzer: 'search_text')
        {
          type: 'text',
          analyzer: analyzer,
          search_analyzer: analyzer,
          fields: {
            keyword: keyword_field
          }
        }
      end
    end
  end
end
