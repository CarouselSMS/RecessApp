class AddDateIndexes < ActiveRecord::Migration
  def self.up
    add_index     :admin_messages,      :created_at
    add_index     :marketing_messages,  :created_at
    add_index     :session_messages,    :created_at
  end

  def self.down
    remove_index  :session_messages,    :created_at
    remove_index  :marketing_messages,  :created_at
    remove_index  :admin_messages,      :created_at
  end
end
