require 'test_helper'

class SubscriptionPlanTest < ActiveSupport::TestCase
  
  context "description" do
    should "unlimited plan" do
      plan = SubscriptionPlan.new(:amount => 79, :trial_period => 15, :setup_amount => 0, :renewal_period => 1, :prepaid_message_count => SubscriptionPlan::UNLIMITED)
      assert_equal "15-day trial, $79.00/mo and unlimited texts after that.", plan.description
    end

    should "basic plan" do
      plan = SubscriptionPlan.new(:amount => 25, :trial_period => 15, :setup_amount => 10, :renewal_period => 1, :prepaid_message_count => 250)
      assert_equal "15-day trial, $10.00 setup fee, $25.00/mo and 250/mo prepaid texts after that.", plan.description
    end
  end

  context "first billing at" do
    should "w/ trial period" do
      plan = SubscriptionPlan.new(:trial_period => 5)
      assert_equal Time.now.advance(:days => 5).to_date, plan.first_billing_at.to_date
    end
    
    should "w/o trial period" do
      plan = SubscriptionPlan.new(:trial_period => nil)
      assert_equal Time.now.to_date, plan.first_billing_at.to_date
    end
  end

end