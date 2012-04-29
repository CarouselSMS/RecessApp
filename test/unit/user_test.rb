require 'test_helper'

class UserTest < ActiveSupport::TestCase

  should_validate_presence_of :name
    
  context "admin login token" do
    setup do
      @user = users(:place1_admin)
    end
    
    should "init and return the token" do
      assert_nil @user.admin_login_token
      
      token = @user.init_admin_login_token
      assert_equal 40, token.size
      
      @user.reload
      assert_equal token, @user.admin_login_token
    end
    
    should "reset the token" do
      @user.init_admin_login_token
      @user.reset_admin_login_token
      
      assert_nil @user.admin_login_token
      @user.reload
      assert_nil @user.admin_login_token
    end
  end
  
end
