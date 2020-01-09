ThinkingSphinx::Index.define :answer, with: :real_time do
  indexes body, sortable: true
  indexes user.first_name, as: :author_first_name, sortable: true
  indexes user.last_name, as: :author_last_name, sortable: true

  has user_id, type: :integer
end
