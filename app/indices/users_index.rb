ThinkingSphinx::Index.define :user, with: :real_time do
  indexes email, sortable: true
  indexes first_name, as: :user_first_name, sortable: true
  indexes last_name, as: :user_last_name, sortable: true

  has last_name, type: :string
end
