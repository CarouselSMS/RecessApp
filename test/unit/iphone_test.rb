require 'test_helper'

class IphoneTest < ActiveSupport::TestCase

  should_validate_presence_of   :udid, :sent
  should_validate_uniqueness_of :udid, :case_sensitive => false

  context "can send free" do
    setup do
      @iphone = Iphone.new(:sent => 1, :blocked => false)
    end
    
    should "return false if blocked" do
      @iphone.blocked = true
      assert !@iphone.can_send_free_messages?
    end
    
    should "return false if ran out of free messages" do
      @iphone.sent = 250
      assert !@iphone.can_send_free_messages?
    end
    
    should "return true when fine" do
      assert @iphone.can_send_free_messages?
    end
  end
  
end
