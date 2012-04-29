class AddDeliveryStatusToSessionMessages < ActiveRecord::Migration
  def self.up
    add_column    :session_messages, :mt_id, :integer
    add_column    :session_messages, :mt_delivery_status, :integer, :default => 0
    add_index     :session_messages, :mt_id
  end

  def self.down
    remove_index  :session_messages, :column => :mt_id
    remove_column :session_messages, :mt_delivery_status
    remove_column :session_messages, :mt_id
  end
end
