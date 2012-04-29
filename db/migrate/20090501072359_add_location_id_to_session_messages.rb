class AddLocationIdToSessionMessages < ActiveRecord::Migration
  def self.up
    add_column    :session_messages, :location_id, :integer
    add_index     :session_messages, :location_id
  end

  def self.down
    remove_index  :session_messages, :location_id
    remove_column :session_messages, :location_id
  end
end
