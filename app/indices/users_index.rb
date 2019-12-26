ThinkingSphinx::Index.define :user, with: :active_record do
  indexes email, sortable: true
  indexes profile.first_name, as: :user_first_name, sortable: true
  indexes profile.last_name, as: :user_last_name, sortable: true

  has profile.last_name, created_at, updated_at
end
