ThinkingSphinx::Index.define :question, with: :real_time do
  indexes title, sortable: true
  indexes body
  indexes user.first_name, as: :author_first_name, sortable: true
  indexes user.last_name, as: :author_last_name, sortable: true

  has user_id, type: :integer
end
