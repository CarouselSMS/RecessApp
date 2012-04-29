require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  context "logged in" do
    setup { login_as :place1_admin }
    
    context "billing" do
      setup { get :billing }
      should_respond_with :success
    end
  end

  context "new" do
    setup { get :new, :local => true, :discount => "", :plan => "basic" }
    should_render_template :new
  end


  context "create" do
    setup do
      @user = User.new(@user_params =
      { 'login' => 'foo', 'email' => 'foo@foo.com',
        'password' => 'password', 'password_confirmation' => 'password' })
      @account = Account.new(@acct_params =
      { 'name' => 'Bob', 'domain' => 'Bob' })

      @account.subscription = subscriptions(:place1_1)
      @account.reference = @reference = references(:reference_without_account1)
      @affiliate = @reference.affiliate
      @request.cookies[AppConfig['reference_cookie_name']] = @reference.cookie_token

      User.expects(:new).at_least_once.with(@user_params).returns(@user)
      Account.expects(:new).at_least_once.with(@acct_params).returns(@account)
      @account.expects(:user=).at_least_once.with(@user)
      @account.expects(:save).at_least_once.returns(true)
    end

    should "register reference account, if user has a reference cookie" do
      assert_difference('@affiliate.reload.accounts_count') do
        post :create, :account => @acct_params, :user => @user_params, :plan => subscription_plans(:basic).name
      end

      assert_equal @reference.account_id, @account.id
    end
  end
end