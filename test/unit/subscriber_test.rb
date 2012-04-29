require 'test_helper'

class SubscriberTest < ActiveSupport::TestCase

  should_belong_to :account
  should_belong_to :phone
  should_validate_presence_of :account_id, :phone_id

  context "creation" do
    should "initialize next renewal date" do
      account = Account.first
      phone   = Phone.first
      
      sub     = account.subscribers.create!(:phone => phone)
      nra     = sub.next_renewal_at
      
      assert nra.between?(1.month.from_now.beginning_of_day, 1.month.from_now.end_of_day)
    end
  end

  context "overuse" do
    setup do
      @plan = stub(:overusage_price => 0.25)
      @acc  = stub(:overuse => 10)
      @sub  = Subscription.new
      @sub.stubs(:account).returns(@acc)
      @sub.stubs(:subscription_plan).returns(@plan)
    end
    
    should "return overuse amount" do
      assert_equal 2.5, @sub.overuse_amount
    end
  end
end
