require 'test_helper'

class MessagingTest < ActiveSupport::TestCase
  
  context "register phone number" do
    setup do
      @account = accounts(:place2)
      @messaging = Messaging.new(@account)
    end
    
    should "create new record" do
      @messaging.send(:register_phone_number, "9876543210")
      assert_not_nil Phone.find_by_number("9876543210")
    end
    
    should "find existing" do
      phone = phones(:one)
      assert_equal phone, @messaging.send(:register_phone_number, "0123456789")
    end
    
    should "set the last account id" do
      assert_equal @account, @messaging.send(:register_phone_number, "0123456789", { :set_last_account => true }).last_account
    end
  end
  
  context "register session message" do
    setup do
      @account    = accounts(:place2)
      @location   = @account.locations.create!(:name => "a")

      SessionMessage.delete_all
      @account.session_message_count = 10 # just to check it doesn't count on the actual number
      @account.save
      @account.reload

      @phone      = Phone.first
      @messaging  = Messaging.new(@account)
      @dlr_message_id      = 123456
            
      @messaging.send(:register_session_message, SessionMessage::KIND_CONFIRMATION, @phone, @location, @dlr_message_id)
      @account.reload

      @msg = @account.session_messages.first
    end
    
    should "add session message to log" do
      assert_equal @phone, @msg.phone
      assert_equal SessionMessage::KIND_CONFIRMATION, @msg.kind
      assert_equal @location, @msg.location
      assert_equal @dlr_message_id, @msg.dlr_message_id
    end
    
    should "increment the session message counter" do
      assert_equal 10, @account.session_message_count
    end
  end
  
  context "register session email" do
    setup do
      @account    = accounts(:place2)
      @location   = @account.locations.create!(:name => "a")

      SessionEmail.delete_all
      @messaging  = Messaging.new(@account)
            
      @messaging.send(:register_session_email, SessionEmail::KIND_CONFIRMATION, "test@email.com", @location)
      @account.reload

      @email = @account.session_emails.first
    end
    
    should "add session email to log" do
      assert_equal "test@email.com", @email.email
      assert_equal SessionEmail::KIND_CONFIRMATION, @email.kind
      assert_equal @location, @email.location
    end
    
    should "increment the session email counter" do
      assert_equal 1, @account.session_email_count
    end
  end
  
  context "find location" do
    setup do
      @account = accounts(:place1)
      @messaging = Messaging.new(@account)
    end
    
    should "return existing location" do
      location = @account.locations.first
      assert_equal location, @messaging.send(:find_location, location.id)
    end
    
    should "return nil for non-existent location" do
      assert_nil @messaging.send(:find_location, 0)
    end
  end
  
  context "send messages" do
    setup do
      service_layer = mock()
      service_layer.stubs(:send_message)

      @account    = accounts(:place2)
      @messaging  = Messaging.new(@account)
      @messaging.stubs(:service_layer).returns(service_layer)
    end

    context "send confirmation" do
      setup { SessionMessage.delete_all; @messaging.send_confirmation("1234567890") }
    
      should "register the phone and set last account" do
        phone = Phone.find_by_number("1234567890")
        assert_equal @account, phone.last_account
      end
    
      should "register the message and update the counter" do
        @account.reload
        assert_equal 0, @account.session_message_count.to_i
      end
      
      should "add session message to the log" do
        msg = SessionMessage.first
        assert_not_nil msg
      end
    end
  
    context "send free confirmation" do
      setup { @messaging.send_free_confirmation("1234567890", @iphone = iphones(:second_use)) }
      
      should "update the :sent of iphone" do
        assert_equal 2, @iphone.reload.sent
      end
    end
    
    context "send confirmation email" do
      setup { @messaging.send_confirmation_email("customer@email.com") }
      
      should "send the message" do
        sent = ActionMailer::Base.deliveries.last
        assert_equal  [ "customer@email.com" ], sent.to
        assert_equal  "Confirmation", sent.subject
        assert        /#{@account.conf_message}/ =~ sent.body
      end
      
      should "register the email in log and update the counter" do
        @account.reload
        assert_equal 1, @account.session_email_count
        assert_not_nil @account.session_emails.first
      end
    end
    
    context "send page" do
      setup { SessionMessage.delete_all; @messaging.send_page("1234567890") }
    
      should "register the phone and set last account" do
        phone = Phone.find_by_number("1234567890")
        assert_equal @account, phone.last_account
      end
    
      should "register the message and update the counter" do
        @account.reload
        assert_equal 1, @account.session_message_count
      end
      
      should "add session message to the log" do
        msg = SessionMessage.first
        assert_not_nil msg
      end
    end
    
    context "send free page" do
      setup { @messaging.send_free_page("1234567890", @iphone = iphones(:second_use)) }
      
      should "update the :sent of iphone" do
        assert_equal 2, @iphone.reload.sent
      end
    end
    
    context "send page email" do
      setup { @messaging.send_page_email("customer@email.com") }
      
      should "send the message" do
        sent = ActionMailer::Base.deliveries.last
        assert_equal  [ "customer@email.com" ], sent.to
        assert_equal  "Notification", sent.subject
        assert        /#{@account.page_message}/ =~ sent.body
      end
      
      should "register the email in log and update the counter" do
        @account.reload
        assert_equal 1, @account.session_email_count
        assert_not_nil @account.session_emails.first
      end
    end
    
  end  
end