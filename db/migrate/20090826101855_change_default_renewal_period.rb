class ChangeDefaultRenewalPeriod < ActiveRecord::Migration
  def self.up
    change_table :subscription_plans do |t|
      t.change_default :trial_period, 15
    end
    
    SubscriptionPlan.update_all("trial_period = 15", 'trial_period = 1')
  end

  def self.down
    SubscriptionPlan.update_all("trial_period = 1", 'trial_period = 15')

    change_table :subscription_plans do |t|
      t.change_default :trial_period, 1
    end
  end
end
