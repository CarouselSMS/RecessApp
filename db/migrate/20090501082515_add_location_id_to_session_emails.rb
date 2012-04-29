class AddLocationIdToSessionEmails < ActiveRecord::Migration
  def self.up
    add_column    :session_emails, :location_id, :integer
    add_index     :session_emails, :location_id
  end

  def self.down
    remove_index  :session_emails, :location_id
    remove_column :session_emails, :location_id
  end
end
