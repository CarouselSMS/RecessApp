require 'test_helper'

class SlCallbacksControllerTest < ActionController::TestCase

  context "incoming message" do
    context "more" do
      setup { get :index, :type => "incoming_message", :phone_number => phones(:one).number, :body => "m" }
      should_respond_with :success
      should "return offer text" do
        assert_equal offers(:place1_1).details, @response.body
      end
    end
  end

  context "delivery report" do
    setup { get :index, :type => "delivery_report", :message_id => (@sm = session_messages(:place1_pending)).dlr_message_id, :status => 1, :final => 1 }
    should_respond_with :success
    should "update the record" do
      @sm.reload
      assert_equal 1, @sm.dlr_status
      assert       @sm.dlr_final
    end
  end
end
