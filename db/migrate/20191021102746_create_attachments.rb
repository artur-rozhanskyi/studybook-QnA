class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.string :file
      t.integer :attachmentable_id, index: true
      t.string :attachmentable_type, index: true

      t.timestamps
    end
  end
end
