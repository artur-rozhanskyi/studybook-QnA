class AddAnswersToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :answers, :user, index: true
  end
end
