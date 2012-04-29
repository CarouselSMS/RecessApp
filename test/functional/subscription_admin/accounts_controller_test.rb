require 'test_helper'

class SubscriptionAdmin::AccountsControllerTest < ActionController::TestCase

  context "sorting accounts" do
    setup { login_into_admin_domain }

    context "without sort" do
      setup { get :index }
      should_assign_to(:accounts) { sorted_accounts('accounts.name') }
    end

    context "sorted by name" do
      setup { get :index, :sort => 'name' }
      should_assign_to(:accounts) { sorted_accounts('accounts.name') }
    end
    
    context "sorted by domain name" do
      setup { get :index, :sort => 'full_domain' }
      should_assign_to(:accounts) { sorted_accounts('accounts.full_domain') }
    end
    
    context "resetting sort" do
      setup { get :index, :sort => '' }
      should_assign_to(:accounts) { sorted_accounts('accounts.name') }
    end
  end
  
  context "rendering csv" do
    setup { login_into_admin_domain }
    
    should "render CSV" do
      get :index, :format => "csv"
      assert_equal "Account,Domain,Venue Name,Venue Address,Venue Type,Plan,State,Revenue,Discount Code,Usage,Subscribers,User Name,E-mail,Cell,Affiliate Name,Affiliate Code\n" +
        "Place 1,place1,place1 name,place1 address,other,Basic,Trial,$30.00,,0,1,,place1_host@example.com,\"\",,\n" +
        "Place 1,place1,place1 name,place1 address,other,Basic,Trial,$30.00,,0,1,,place1_admin@example.com,\"\",,\n" +
        "Place 2,2place,place2 name,place2 address,other,Basic,Active,$0.00,bar,0,0,,,,,\n" +
        "Place 3,place3,place3 name,place3 address,other,,,$0.00,,0,0,,,,,\n", @response.body
    end
  end
  
  context "logging into accounts" do
    setup do
      login_into_admin_domain
      @account = accounts(:place1)
    end

    should "log in using a given user" do
      user = @account.users.first
      get :login_with_user, :id => @account.id, :uid => user.id

      user.reload
      assert_not_nil user.admin_login_token
      assert_redirected_to "http://#{@account.full_domain}/session/create_as_admin?token=#{user.admin_login_token}"
    end
    
    should "redirect to the account details if user doesn't exist" do
      get :login_with_user, :id => @account.id, :uid => 0
      assert_redirected_to admin_account_url(@account)
    end
  end
   
  private
  
  def sorted_accounts(order)
    Account.paginate(:page => nil, :per_page => 30, :order => order)
  end 
end