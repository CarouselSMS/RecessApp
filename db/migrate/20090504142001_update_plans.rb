class UpdatePlans < ActiveRecord::Migration
  def self.up
    SubscriptionPlan.update_all("amount = 29.95, trial_period = 1", "amount = 30")
    SubscriptionPlan.update_all("amount = 34.95, trial_period = 1", "amount = 35")
  end

  def self.down
    SubscriptionPlan.update_all("amount = 30, trial_period = 1", "amount = 29.95")
    SubscriptionPlan.update_all("amount = 35, trial_period = 1", "amount = 34.95")
  end
end
