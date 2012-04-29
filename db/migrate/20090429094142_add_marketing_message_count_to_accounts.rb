class AddMarketingMessageCountToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :marketing_message_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :accounts, :marketing_message_count
  end
end
