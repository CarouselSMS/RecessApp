class UpdateDlrFields < ActiveRecord::Migration
  def self.up
    rename_column :session_messages, :mt_id, :dlr_message_id
    rename_column :session_messages, :mt_delivery_status, :dlr_status
    add_column    :session_messages, :dlr_final, :boolean, :default => false
  end

  def self.down
    remove_column :session_messages, :dlr_final
    rename_column :session_messages, :dlr_status, :mt_delivery_status
    rename_column :session_messages, :dlr_message_id, :mt_id
  end
end
