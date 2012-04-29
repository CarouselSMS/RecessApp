require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  
  context "login / logout" do
    setup do
      @user     = users(:place1_admin)
      @account  = @user.account
      @controller.stubs(:current_account).returns(@account)
    end

    context "login as admin" do
      setup { @token = @user.init_admin_login_token }
      context "valid login token" do
        setup { get :create_as_admin, :token => @token }
        should_redirect_to("dashboard") { dashboard_url }
        should "reset admin login token" do
          @user.reload
          assert_nil @user.admin_login_token
        end
        should "set session flag" do
          assert session[:logged_in_with_admin_token]
        end
      end
    
      context "invalid login token" do
        setup { get :create_as_admin, :token => @token.reverse }
        should_render_template :new
      end
    end

    context "login as normal user" do
      context "valid u/p should not set the session flag" do
        setup { get :create, :login => "place1_admin", :password => "test" }
        should_redirect_to("dashboard")  { dashboard_url }
        should "not set the session flag" do
          assert_nil session[:logged_in_with_admin_token]
        end
      end
      
      context "invalid u/p" do
        setup { get :create, :login => "place1_admin", :password => "wrong_password" }
        should_render_template :new
        should_set_the_flash_to /couldn't/i
      end
    end

    context "logout as admin" do
      setup do
        login_as :place1_admin
        @controller.stubs(:logging_out_as_admin?).returns(true)
        get :destroy
      end
      should_redirect_to("Account info") { "http://#{AppConfig['admin_subdomain']}.#{AppConfig['base_domain']}#{admin_account_path(@account)}" }
    end
    
    context "logout as normal user" do
      setup do
        login_as :place1_admin
        @controller.stubs(:logging_out_as_admin?).returns(nil)
        get :destroy
      end
      should_redirect_to("dashboard")  { dashboard_url }
    end
  end
end