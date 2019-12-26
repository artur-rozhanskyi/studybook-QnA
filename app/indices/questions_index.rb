ThinkingSphinx::Index.define :question, with: :active_record do
  indexes title, sortable: true
  indexes body
  indexes user.profile.first_name, as: :author_first_name, sortable: true
  indexes user.profile.last_name, as: :author_last_name, sortable: true

  has user_id, created_at, updated_at
end
