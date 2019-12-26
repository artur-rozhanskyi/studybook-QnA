class CreateJoinTableQuestionsUsers < ActiveRecord::Migration[5.2]
  def change
    create_join_table :questions, :users
  end
end
