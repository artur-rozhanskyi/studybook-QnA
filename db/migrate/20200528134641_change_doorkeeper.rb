class ChangeDoorkeeper < ActiveRecord::Migration[5.2]
  def change
    change_column_null :oauth_access_tokens, :application_id, true
  end
end
