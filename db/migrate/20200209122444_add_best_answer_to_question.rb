class AddBestAnswerToQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :best_answer_id, :integer, null: true
    add_foreign_key :questions, :answers, column: :best_answer_id
  end
end
