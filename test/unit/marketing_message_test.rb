require 'test_helper'

class MarketingMessageTest < ActiveSupport::TestCase

  should_belong_to :account
  should_validate_presence_of :account_id, :kind

  context "creation" do
    should "pre-populate the total" do
      mm = MarketingMessage.create!(:account => accounts(:place1), :kind => MarketingMessage::KIND_MANUAL, :parts => 2, :recipients => 3)
      assert_equal 6, mm.total
    end
  end
  
end
