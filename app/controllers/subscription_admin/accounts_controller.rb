class SubscriptionAdmin::AccountsController < ApplicationController
  include ModelControllerMethods
  include AdminControllerMethods
  include ActionView::Helpers::NumberHelper
  
  def index
    respond_to do |wants|
      wants.html do
        session[:accounts_order] = (params[:sort].blank? ? nil : params[:sort]) if params[:sort]
        order = session[:accounts_order] || 'name'
        @accounts = Account.paginate(:include => [:subscription, :affiliate], :page => params[:page], :per_page => 30, :order => "accounts.#{order}")
      end
      wants.csv do
        @accounts = Account.all(:order => 'accounts.name')
        render_accounts_csv(@accounts)
      end
    end
  end
  
  # Logs into this account with the given user
  def login_with_user
    load_object
    user = @account.users.find(params[:uid])
    token = user.init_admin_login_token
    redirect_to "http://#{@account.full_domain}/session/create_as_admin?token=#{token}"
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_account_url(@account)
  end
  
  private
  
  # Renders the accounts CSV
  def render_accounts_csv(accounts)
    max = min = nil

    # - Account
    # name
    # full_domain
    # venue_name
    # venue_address
    # venue_type (or venue_type_other)
    # Plan name
    # State
    # Total amount charged on card
    # Discount code entered
    # Messages used (marketing, admin, pages)
    # Number of subscribers
    # - User
    # name
    # email
    # mobile
    # - Affiliate
    # name
    # code (slug)
    
    csv = FasterCSV.generate do |data|
      data << [ "Account", "Domain", "Venue Name", "Venue Address", "Venue Type", "Plan", "State", "Revenue", "Discount Code", "Usage", "Subscribers", "User Name", "E-mail", "Cell", "Affiliate Name", "Affiliate Code" ]
      accounts.each do |account|
        account_type   = account.venue_type == "Other" ? account.venue_type_other : account.venue_type
        subscription   = account.subscription
        
        account_fields = [
          account.name,
          account.domain,
          account.venue_name,
          account.venue_address,
          account_type,
          subscription && subscription.subscription_plan.name,
          subscription && subscription.state.capitalize,
          number_to_currency(account.subscription_payments.sum(:amount)),
          subscription && subscription.discount && subscription.discount.code,
          account.usage,
          account.subscribers.count ]

        affiliate_fields = if account.affiliate.nil?
          [ nil, nil ]
        else
          [ account.affiliate.name, account.affiliate.slug ]
        end
          
        users = account.users
        if users.empty?
          data << account_fields + [ nil, nil, nil ] + affiliate_fields
        else
          users.each do |user|
            data << account_fields + [ user.name, user.email, SmsToolkit::PhoneNumbers.format(user.mobile) ] + affiliate_fields
          end
        end
      end
    end

    render_csv csv, "accounts-#{Time.now.to_s(:ymd)}"
  end

  # Sets the tab
  def set_selected_tab
    self.selected_tab = :accounts
  end
  
end
