class AddSessionMessagesToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :session_message_count, :integer
  end

  def self.down
    remove_column :accounts, :session_message_count
  end
end
