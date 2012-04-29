require 'test_helper'
include ActiveMerchant::Billing

class SubscriptionTest < ActiveSupport::TestCase
    
  context "creating a payment record" do
    should "save the record" do
      sub = subscriptions(:place1_1)
      account = sub.account
      total = 2
      tr_id = 3
      payment = sub.send(:create_payment_record, total, tr_id)
      
      assert_equal sub.subscription_plan.prepaid_message_count, payment.prepaid_messages
      assert_equal account.session_message_count,               payment.session_messages
      assert_equal account.admin_message_count,                 payment.admin_messages
      assert_equal account.marketing_message_count,             payment.marketing_messages
    end
  end

  context "unlimited messaging" do
    should "return TRUE if plan is for unlim" do
      plan = SubscriptionPlan.new(:prepaid_message_count => SubscriptionPlan::UNLIMITED, :amount => 1)
      sub  = Subscription.new(:plan => plan)
      assert sub.unlimited_messaging?
    end
    
    should "return FALSE for prepaid plan" do
      plan = SubscriptionPlan.new(:prepaid_message_count => 250, :amount => 1)
      sub  = Subscription.new(:plan => plan)
      assert !sub.unlimited_messaging?
    end
  end
end
