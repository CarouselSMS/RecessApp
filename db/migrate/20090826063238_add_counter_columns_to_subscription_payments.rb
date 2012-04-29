class AddCounterColumnsToSubscriptionPayments < ActiveRecord::Migration
  def self.up
    add_column :subscription_payments, :prepaid_messages,   :integer
    add_column :subscription_payments, :session_messages,   :integer
    add_column :subscription_payments, :admin_messages,     :integer
    add_column :subscription_payments, :marketing_messages, :integer
  end

  def self.down
    remove_column :subscription_payments, :marketing_messages
    remove_column :subscription_payments, :admin_messages
    remove_column :subscription_payments, :session_messages
    remove_column :subscription_payments, :prepaid_messages
  end
end
