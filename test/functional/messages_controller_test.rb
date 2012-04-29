require 'test_helper'

class MessagesControllerTest < ActionController::TestCase

  context "index" do
    setup do
      login_as :place1_admin
      @account = accounts(:place1)
      get :index
    end

    should_respond_with     :success
    should_render_template  :index
    should_assign_to(:account) { @account }
  end

  context "update" do
    setup do
      login_as :place1_admin
      post :update, :account => {
        :conf_message       => "new conf message",
        :conf_prepend_venue => true,
        :page_message       => "new page message",
        :page_prepend_venue => true,
        :offer_id           => offers(:place1_1).id }
    end
    
    should_redirect_to('dashboard') { dashboard_url }
    should_set_the_flash_to "Messages were updated"
    should "update account" do
      @account = accounts(:place1)
      assert_equal "new conf message", @account.conf_message
      assert       @account.conf_prepend_venue
      assert_equal "new page message", @account.page_message
      assert       @account.page_prepend_venue
      assert       offers(:place1_1), @account.current_offer
    end
  end
  
  context "sending test offer" do
    setup do
      login_as :place1_admin
      @sl = mock()
      @controller.stubs(:service_layer).returns(@sl)
    end
    
    context "valid" do
      setup do
        @controller.current_account.marketing_messages.clear
        @sl.expects(:send_message).with('9000000001', 'details', false).once
        post :send_test_offer, :offer => { :details => "details" }, :phone_number => "9000000001"
      end
      should "render 'Sent'" do
        assert_equal "Sent", @response.body
      end
      should "register the marketing message" do
        acc = @controller.current_account
        msg = acc.marketing_messages.first
        assert_equal MarketingMessage::KIND_OFFER_DETAILS, msg.kind
        assert_equal "details", msg.body
      end
    end
    
    context "empty details" do
      setup do
        @sl.expects(:send_message).with('9000000001', '', false).never
        post :send_test_offer, :offer => { :details => "" }, :phone_number => "9000000001"
      end
      should "render 'Details can't be empty'" do
        assert_equal "Details can't be empty", @response.body
      end
    end

    context "long details" do
      setup do
        @sl.expects(:send_message).with('9000000001', 'a' * 200, false).never
        post :send_test_offer, :offer => { :details => 'a' * 200 }, :phone_number => "9000000001"
      end
      should "render 'Details is too long (maximum is 160 characters)'" do
        assert_equal "Details is too long (maximum is 160 characters)", @response.body
      end
    end
    
    context "phone missing" do
      setup do
        @sl.expects(:send_message).with('9000000001', 'a', false).never
        post :send_test_offer, :offer => { :details => 'a' }, :phone_number => ""
      end
      should "render 'Phone number is blank'" do
        assert_equal "Phone number is blank", @response.body
      end
    end
  end
end
