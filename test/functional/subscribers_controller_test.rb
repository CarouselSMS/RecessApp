require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase

  context "logged in" do
    setup do
      @account = accounts(:place1)
      login_as :place1_admin
    end
    
    context "index" do
      setup { get :index }
      should_respond_with :success
      should_assign_to(:message_count) { @account.marketing_messages.manual.count }
    end
    
    context "message log" do
      setup { get :message_log }
      should_respond_with :success
      should_assign_to(:messages) { @account.marketing_messages.manual.paginate(:page => 1, :per_page => 50, :order => "created_at DESC") }
    end
    
    context "send message" do
      setup { get :send_message, :message => { :body => "abc" } }
      should_redirect_to("index") { subscribers_url }
    end
  end

end
