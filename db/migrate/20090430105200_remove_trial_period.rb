class RemoveTrialPeriod < ActiveRecord::Migration
  def self.up
    SubscriptionPlan.update_all("trial_period = NULL")
  end

  def self.down
  end
end
