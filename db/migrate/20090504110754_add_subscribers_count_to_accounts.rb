class AddSubscribersCountToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :subscribers_count, :integer, :null => false, :default => 0
    
    Account.reset_column_information
    Account.all.each { |a| a.update_attribute(:subscribers_count, a.subscribers.length) }
  end

  def self.down
    remove_column :accounts, :subscribers_count
  end
end
