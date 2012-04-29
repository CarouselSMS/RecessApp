class AddPrepaidMessageCountToSubscriptionPlans < ActiveRecord::Migration
  def self.up
    add_column :subscription_plans,     :prepaid_message_count, :integer, :null => false, :default => 250
    add_column :subscriptions,          :prepaid_message_count, :integer, :null => false, :default => 250
  end

  def self.down
    remove_column :subscriptions,       :prepaid_message_count
    remove_column :subscription_plans,  :prepaid_message_count
  end
end
