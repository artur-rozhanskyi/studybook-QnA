module Search
  module Indexes
    module IndexLifecycle
      def ensure_index!(client)
        return if client.indices.exists_alias(name: alias_name)

        create_index!(client, versioned_index_name(1))
        switch_alias!(client, versioned_index_name(1))
      end

      def create_index!(client, index_name)
        client.indices.create(index: index_name, body: definition)
      end

      def current_index_name(client)
        return nil unless client.indices.exists_alias(name: alias_name)

        client.indices.get_alias(name: alias_name).keys.first
      end

      def next_versioned_index_name(client)
        current_version = version_from_index_name(current_index_name(client))
        versioned_index_name(current_version ? current_version + 1 : 1)
      end

      def switch_alias!(client, new_index_name, old_index_name: nil)
        actions = alias_actions(new_index_name, old_index_name)
        client.indices.update_aliases(body: { actions: actions })
      end

      def delete_index!(client, index_name)
        return if index_name.blank?

        client.indices.delete(index: index_name)
      end

      private

      def alias_actions(new_index_name, old_index_name)
        actions = []
        if old_index_name.present? && old_index_name != new_index_name
          actions << { remove: { index: old_index_name, alias: alias_name } }
        end
        actions << { add: { index: new_index_name, alias: alias_name } }
        actions
      end

      def version_from_index_name(index_name)
        index_name.to_s[/_v(\d+)$/, 1]&.to_i
      end
    end
  end
end
