module Search
  module Indexes
    class UserIndex < Base
      def self.model_class
        ::User
      end

      def self.searchable_fields
        ['email^3', 'first_name^2', 'last_name^2', 'full_name']
      end

      def self.properties
        {
          id: id_field,
          email: text_field,
          first_name: text_field,
          last_name: text_field,
          full_name: text_field,
          role: keyword_field,
          created_at: date_field,
          updated_at: date_field
        }
      end

      def self.document_for(user)
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          full_name: [user.first_name, user.last_name].compact.join(' '),
          role: user.role,
          created_at: user.created_at&.iso8601,
          updated_at: user.updated_at&.iso8601
        }
      end

      def self.database_scope(text)
        query = sanitize_query(text)
        model_class.left_joins(:profile).where(
          'users.email ILIKE :query OR profiles.first_name ILIKE :query OR profiles.last_name ILIKE :query OR
           CONCAT(COALESCE(profiles.first_name, \'\'), \' \', COALESCE(profiles.last_name, \'\')) ILIKE :query',
          query: query
        ).distinct
      end
    end
  end
end
