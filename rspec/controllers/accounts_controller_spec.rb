require File.dirname(__FILE__) + '/../spec_helper'
include ActiveMerchant::Billing

describe AccountsController do
  before(:each) do
    controller.stubs(:current_account).returns(@account = accounts(:localhost))
  end
  
  describe "creating a new account" do
    before(:each) do
      @user = User.new(@user_params = 
      { 'login' => 'foo', 'email' => 'foo@foo.com',
        'password' => 'password', 'password_confirmation' => 'password' })
      @account = Account.new(@acct_params = 
      { 'name' => 'Bob', 'domain' => 'Bob' })
      User.expects(:new).with(@user_params).returns(@user)
      Account.expects(:new).with(@acct_params).returns(@account)
    @account.expects(:user=).with(@user)
    @account.expects(:save).returns(true)
    end
    
    it "should create one" do
      post :create, :account => @acct_params, :user => @user_params, :plan => subscription_plans(:basic).name
    flash[:domain].should == @account.domain
      response.should redirect_to(thanks_url)
    end

    it "should assign the creditcard and address if payment info is needed" do
      @account.expects(:needs_payment_info?).returns(true)
      @account.expects(:creditcard=)
      @account.expects(:address=)
      post :create, :account => @acct_params, :user => @user_params, :plan => subscription_plans(:basic).name
  end
  
    it "should not assign the creditcard and address if payment info is not needed" do
      @account.expects(:needs_payment_info?).returns(false)
      @account.expects(:creditcard=).never
      @account.expects(:address=).never
      post :create, :account => @acct_params, :user => @user_params, :plan => subscription_plans(:basic).name
    end
  end

  describe "plan list" do
    it "should list plans with the most expensive first" do
      get :plans
      assigns(:plans).should == SubscriptionPlan.find(:all, :order => 'amount desc')
    end
  
    it "should apply a discount to plans, if supplied" do
      @discount = subscription_discounts(:sub)
      get :plans, :discount => @discount.code
      assigns(:plans).first.discount.should == @discount
    end
  end
    
  describe "loading the account creation page" do
    before(:each) do
      @plan = subscription_plans(:basic)
      get :new, :plan => @plan.name
    end
    
    it "should load the plan by name" do
      assigns(:plan).should == @plan
    end
    
    it "should prep payment and address info" do
      assigns(:creditcard).should_not be_nil
      assigns(:address).should_not be_nil
    end
    
    it "should apply a discount to the plan, if supplied" do
      @discount = subscription_discounts(:sub)
      get :new, :plan => @plan.name, :discount => @discount.code
      assigns(:plan).discount.should == @discount
    end
  end
  
  describe 'updating an existing account' do
    it 'should prevent a non-admin from updating' do
      controller.stubs(:current_user).returns(users(:aaron))
      put :update, :account => { :name => 'Foo' }
      response.should redirect_to(new_session_url)
    end
    
    it 'should allow an admin to update' do
      controller.stubs(:current_user).returns(users(:quentin))
      @account.expects(:update_attributes).with('name' => 'Foo').returns(true)
      put :update, :account => { :name => 'Foo' }
      response.should redirect_to(account_url)
    end
  end
  
  describe "changing a plan" do
    before(:each) do
      controller.stubs(:current_user).returns(@account.admin)
    end
    
    it "should apply the existing discount to the plans in the plan list" do
      @account.subscription.stubs(:discount).returns(@discount = subscription_discounts(:sub))
      get :plan
      assigns(:plans).first.discount.should == @discount
    end
  end
  
  describe "updating billing info" do
    before(:each) do
      controller.stubs(:current_user).returns(@account.admin)
    end
    
    it "should store the card when it and the address are valid" do
      CreditCard.stubs(:new).returns(@card = mock('CreditCard', :valid? => true, :first_name => 'Bo', :last_name => 'Peep'))
      SubscriptionAddress.stubs(:new).returns(@address = mock('SubscriptionAddress', :valid? => true, :to_activemerchant => 'foo'))
      @address.expects(:first_name=).with('Bo')
      @address.expects(:last_name=).with('Peep')
      @account.subscription.expects(:store_card).with(@card, :billing_address => 'foo', :ip => '0.0.0.0').returns(true)
      post :billing, :creditcard => {}, :address => {}      
    end
    
    describe "with paypal" do
      it "should redirect to paypal to start the process" do
        @account.subscription.expects(:start_paypal).with('http://test.host/account/paypal', 'http://test.host/account/billing').returns('http://foo')
        post :billing, :paypal => 'true'
        response.should redirect_to('http://foo')
      end
      
      it "should go nowhere if the paypal token request fails" do
        @account.subscription.expects(:start_paypal).returns(nil)
        post :billing, :paypal => 'true'
        response.should render_template('accounts/billing')
      end
      
      it "should set the subscription info from the paypal response" do
        @account.subscription.expects(:complete_paypal).with('bar').returns(true)
        get :paypal, :token => 'bar'
        response.should redirect_to(billing_account_url)
      end
      
      it "should render the form when encountering problems with the paypal return" do
        @account.subscription.expects(:complete_paypal).with('bar').returns(false)
        get :paypal, :token => 'bar'
        response.should render_template('accounts/billing')
      end
    end
  end
  
  describe "when canceling" do
    before(:each) do
      controller.stubs(:current_user).returns(users(:quentin))
    end
    
    it "should not destroy the account without confirmation" do
      @account.expects(:destroy).never
      post :cancel
      response.should render_template('cancel')
    end
    
    it "should destroy the account" do
      @account.expects(:destroy).returns(true)
      post :cancel, :confirm => 1
      response.should redirect_to("http://#{AppConfig['base_domain']}")
    end

    it "should log out the user" do
      @account.stubs(:destroy).returns(true)
      controller.expects(:current_user=).with(nil)
      post :cancel, :confirm => 1
    end
  end
end
