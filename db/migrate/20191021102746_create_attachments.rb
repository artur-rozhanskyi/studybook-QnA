class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.string :file

      t.timestamps
    end

    add_reference :attachments, :question, index: true
  end
end
