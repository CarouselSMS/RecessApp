class AddSslAllowedColumn < ActiveRecord::Migration
  def self.up
    add_column :subscriptions,          :ssl_allowed, :boolean, :default => false
    add_column :subscription_plans,     :ssl_allowed, :boolean, :default => false

    SubscriptionPlan.reset_column_information
    SubscriptionPlan.create!({
      :name                   => 'Basic with SSL', 
      :amount                 => 35, 
      :user_limit             => nil, 
      :trial_period           => nil, 
      :prepaid_message_count  => 250, 
      :ssl_allowed            => true })
  end

  def self.down
    SubscriptionPlan.find_by_name('Basic with SSL').destroy
    remove_column :subscriptions,       :ssl_allowed
    remove_column :subscription_plans,  :ssl_allowed
  end
end
