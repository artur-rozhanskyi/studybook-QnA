module Search
  module Indexes
    class QuestionIndex < Base
      def self.model_class
        ::Question
      end

      def self.searchable_fields
        ['title^3', 'body']
      end

      def self.properties
        {
          id: id_field,
          title: text_field,
          body: text_field,
          user_id: long_field,
          best_answer_id: long_field,
          created_at: date_field,
          updated_at: date_field
        }
      end

      def self.document_for(question)
        {
          id: question.id,
          title: question.title,
          body: question.body,
          user_id: question.user_id,
          best_answer_id: question.best_answer_id,
          created_at: question.created_at&.iso8601,
          updated_at: question.updated_at&.iso8601
        }
      end

      def self.database_scope(text)
        query = sanitize_query(text)
        model_class.where('title ILIKE :query OR body ILIKE :query', query: query)
      end
    end
  end
end
