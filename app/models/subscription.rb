class Subscription < ActiveRecord::Base

  belongs_to :account
  belongs_to :subscription_plan
  has_many :subscription_payments
  belongs_to :discount, :class_name => 'SubscriptionDiscount', :foreign_key => 'subscription_discount_id'
  
  before_create :set_renewal_at
  before_update :apply_discount
  before_destroy :destroy_gateway_record
  
  attr_accessor :creditcard, :address
  attr_reader :response
  
  # renewal_period is the number of months to bill at a time
  # default is 1
  validates_numericality_of :renewal_period, :only_integer => true, :greater_than => 0
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  validate_on_create :card_storage
  
  # This hash is used for validating the subscription when a plan
  # is changed.  It includes both the validation rules and the error
  # message for each limit to be checked.
  Limits = {
    Proc.new {|account, plan| !plan.user_limit || plan.user_limit >= Account::Limits['user_limit'].call(account) } => 
      'User limit for new plan would be exceeded.  Please delete some users and try again.'
  }
  
  # Changes the subscription plan, and assigns various properties, 
  # such as limits, etc., to the subscription from the assigned 
  # plan.  When adding new limits that are specified in 
  # SubscriptionPlan, don't forget to add those new fields to the 
  # assignments in this method.
  def plan=(plan)
    if plan.amount > 0
      # Discount the plan with the existing discount (if any)
      # if the plan doesn't already have a better discount
      plan.discount = discount if discount && discount > plan.discount
      # If the assigned plan has a better discount, though, then
      # assign the discount to the subscription so it will stick
      # through future plan changes
      self.discount = plan.discount if plan.discount && plan.discount > discount
    else
      # Free account from the get-go?  No point in having a trial
      self.state = 'active' if new_record?
    end
    
    [:amount, :user_limit, :renewal_period, :prepaid_message_count, :ssl_allowed].each do |f|
      self.send("#{f}=", plan.send(f))
    end
    
    self.subscription_plan = plan
  end
  
  # The plan_id and plan_id= methods are convenience methods for the
  # administration interface.
  def plan_id
    subscription_plan_id
  end
  
  def plan_id=(a_plan_id)
    self.plan = SubscriptionPlan.find(a_plan_id) if a_plan_id.to_i != subscription_plan_id
  end
  
  def trial_days
    (self.next_renewal_at.to_i - Time.now.to_i) / 86400
  end

  def unlimited_messaging?
    self.prepaid_message_count >= SubscriptionPlan::UNLIMITED
  end

  def overuse_amount
    account.overuse * subscription_plan.overusage_price
  end
  
  def amount_in_pennies
    (amount * 100).to_i
  end
  
  def store_card(creditcard, gw_options = {})
    # Clear out payment info if switching to CC from PayPal
    destroy_gateway_record(paypal) if paypal?
    
    @response = if billing_id.blank?
      gateway.store(creditcard, gw_options)
    else
      gateway.update(billing_id, creditcard, gw_options)
    end
    
    if @response.success?
      self.card_number = creditcard.display_number
      self.card_expiration = "%02d-%d" % [creditcard.expiry_date.month, creditcard.expiry_date.year]
      set_billing
    else
      errors.add_to_base(@response.message)
      false
    end
  end
  
  # Charge the card on file the amount stored for the subscription
  # record.  This is called by the daily_mailer script for each 
  # subscription that is due to be charged.  A SubscriptionPayment
  # record is created, and the subscription's next renewal date is 
  # set forward when the charge is successful.
  def charge
    full_amount = amount + overuse_amount
    if full_amount == 0 || (@response = gateway.purchase(full_amount * 100, billing_id)).success?
      update_attributes(:next_renewal_at => self.next_renewal_at.advance(:months => self.renewal_period), :state => 'active')

      create_payment_record(full_amount, @response.authorization) unless full_amount == 0
      
      # Release the account
      account.update_attribute(:on_hold, false)
      account.reset_usage
      
      true
    else
      errors.add_to_base(@response.message)
      false
    end
  end

  # Charge the card on file any amount you want.  Pass in a dollar
  # amount (1.00 to charge $1).  A SubscriptionPayment record will
  # be created, but the subscription itself is not modified.
  def misc_charge(amount)
    if amount == 0 || (@response = gateway.purchase((amount.to_f * 100).to_i, billing_id)).success?
      subscription_payments.create(:account => account, :amount => amount, :transaction_id => @response.authorization, :misc => true)
      true
    else
      errors.add_to_base(@response.message)
      false
    end
  end
  
  def start_paypal(return_url, cancel_url)
    if (@response = paypal.setup_authorization(:return_url => return_url, :cancel_return_url => cancel_url, :description => AppConfig['app_name'])).success?
      paypal.redirect_url_for(@response.params['token'])
    else
      errors.add_to_base("PayPal Error: #{@response.message}")
      false
    end
  end
  
  def complete_paypal(token)
    if (@response = paypal.details_for(token)).success?
      if (@response = paypal.create_billing_agreement_for(token)).success?
        # Clear out payment info if switching to PayPal from CC
        destroy_gateway_record(cc) unless paypal?

        self.card_number = 'PayPal'
        self.card_expiration = 'N/A'
        set_billing
      else
        errors.add_to_base("PayPal Error: #{@response.message}")
        false
      end
    else
      errors.add_to_base("PayPal Error: #{@response.message}")
      false
    end
  end
  
  def needs_payment_info?
    self.card_number.blank? && self.subscription_plan.amount > 0
  end

  def self.find_expiring_trials(renew_at = 7.days.from_now)
    find(:all, :include => :account, :conditions => { :state => 'trial', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) })
  end
  
  def self.find_due_trials(renew_at = Time.now)
    find(:all, :include => :account, :conditions => { :state => 'trial', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) }).select {|s| !s.card_number.blank? }
  end
  
  def self.find_due(renew_at = Time.now)
    find(:all, :include => :account, :conditions => { :state => 'active', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) })
  end

  # Finds accounts that had to be renewed 7 days ago
  def self.find_for_hold
    find_due(7.days.ago)
  end
  
  def paypal?
    card_number == 'PayPal'
  end
  
  def current?
    next_renewal_at >= Time.now
  end

  def on_hold?
    account && account.on_hold?
  end
  
  protected
  
  def set_billing
    self.billing_id = @response.token unless @response.token.blank?
    
    if new_record?
      if !next_renewal_at? || next_renewal_at < 1.day.from_now.at_midnight
        if subscription_plan.trial_period?
          self.next_renewal_at = Time.now.advance(:days => subscription_plan.trial_period)
        else
          charge_amount = subscription_plan.setup_amount? ? subscription_plan.setup_amount : amount
          if (@response = gateway.purchase(charge_amount * 100, billing_id)).success?
            build_payment_record(charge_amount, @response.authorization)
            self.state = 'active'
            self.next_renewal_at = Time.now.advance(:months => renewal_period)
          else
            errors.add_to_base(@response.message)
            return false
          end
        end
      end
    else
      if !next_renewal_at? || next_renewal_at < 1.day.from_now.at_midnight
        full_amount = amount + overuse_amount
        if (@response = gateway.purchase(full_amount * 100, billing_id)).success?

          create_payment_record(full_amount, @response.authorization)
          account.reset_usage
          
          self.state = 'active'
          self.next_renewal_at = Time.now.advance(:months => renewal_period)
        else
          errors.add_to_base(@response.message)
          return false
        end
      else
        self.state = 'active'
      end
      self.save
    end
  
    true
  end
  
  def set_renewal_at
    return if self.subscription_plan.nil? || self.next_renewal_at
    self.next_renewal_at = Time.now.advance(:months => self.renewal_period)
  end
  
  # If the discount is changed, set the amount to the discounted
  # plan amount with the new discount.
  def apply_discount
    if subscription_discount_id_changed?
      subscription_plan.discount = discount
      self.amount = subscription_plan.amount
    end
  end
  
  def validate_on_update
    return unless self.subscription_plan.updated?
    Limits.each do |rule, message|
      unless rule.call(self.account, self.subscription_plan)
        errors.add_to_base(message)
      end
    end
  end
  
  def gateway
    paypal? ? paypal : cc
  end
  
  def paypal
    @paypal ||=  ActiveMerchant::Billing::Base.gateway(:paypal_express_reference_nv).new(config_from_file('paypal.yml'))
  end
  
  def cc
    @cc ||= ActiveMerchant::Billing::Base.gateway(AppConfig['gateway']).new(config_from_file('gateway.yml'))
  end

  def destroy_gateway_record(gw = gateway)
    return if billing_id.blank?
    gw.unstore(billing_id)
    self.card_number = nil
    self.card_expiration = nil
    self.billing_id = nil
  end
  
  def card_storage
    self.store_card(@creditcard, :billing_address => @address.to_activemerchant) if @creditcard && @address && card_number.blank?
  end
  
  def config_from_file(file)
    YAML.load_file(File.join(RAILS_ROOT, 'config', file))[RAILS_ENV].symbolize_keys
  end
  
  # Creates a payment record
  def create_payment_record(full_amount, transaction_id)
    subscription_payments.create({
      :account            => account,
      :amount             => full_amount,
      :prepaid_messages   => subscription_plan.prepaid_message_count,
      :session_messages   => account.session_message_count,
      :admin_messages     => account.admin_message_count,
      :marketing_messages => account.marketing_message_count,
      :transaction_id     => transaction_id })
  end
  
  # Buids a payment record.
  # Message counters aren't initialized because this method is used during
  # the new account initialization when there's no usage.
  def build_payment_record(full_amount, transaction_id)
    subscription_payments.build({
      :account            => account, 
      :amount             => full_amount, 
      :transaction_id     => @response.authorization, 
      :setup              => subscription_plan.setup_amount? })
  end
end
