class AddQuestionsToAttachment < ActiveRecord::Migration[5.2]
  def change
    add_reference :attachments, :question, index: true
  end
end
