module Search
  module Indexes
    class CommentIndex < Base
      def self.model_class
        ::Comment
      end

      def self.searchable_fields
        ['body']
      end

      def self.properties
        {
          id: id_field,
          body: text_field,
          commentable_type: keyword_field,
          commentable_id: long_field,
          user_id: long_field,
          created_at: date_field,
          updated_at: date_field
        }
      end

      def self.document_for(comment)
        {
          id: comment.id,
          body: comment.body,
          commentable_type: comment.commentable_type,
          commentable_id: comment.commentable_id,
          user_id: comment.user_id,
          created_at: comment.created_at&.iso8601,
          updated_at: comment.updated_at&.iso8601
        }
      end

      def self.database_scope(text)
        query = sanitize_query(text)
        model_class.where('body ILIKE :query', query: query)
      end
    end
  end
end
