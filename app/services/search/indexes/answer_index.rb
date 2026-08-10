module Search
  module Indexes
    class AnswerIndex < Base
      def self.model_class
        ::Answer
      end

      def self.searchable_fields
        ['body']
      end

      def self.properties
        {
          id: id_field,
          body: text_field,
          question_id: long_field,
          user_id: long_field,
          created_at: date_field,
          updated_at: date_field
        }
      end

      def self.document_for(answer)
        {
          id: answer.id,
          body: answer.body,
          question_id: answer.question_id,
          user_id: answer.user_id,
          created_at: answer.created_at&.iso8601,
          updated_at: answer.updated_at&.iso8601
        }
      end

      def self.database_scope(text)
        query = sanitize_query(text)
        model_class.where('body ILIKE :query', query: query)
      end
    end
  end
end
