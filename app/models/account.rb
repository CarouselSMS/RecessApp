class Account < ActiveRecord::Base

  STANDARD_FOOTER       = "Text STOP to end messages,\nHELP for help\nStd msg charges apply\nmanaged by RecessApp.com"
  DEFAULT_PAGE_MESSAGE  = "This is the page. You should change these in your account :)"
  DEFAULT_CONF_MESSAGE  = "This message is to confirm addition to the waitlist."
  
  VENUE_TYPES = [
    "Restaurant",
    "Automotive",
    "Medical",
    "Pharmacy",
    "Entertainment",
    "Government",
    "Travel",
    "Hospitality",
    [ "Other (please specify)", "Other" ]
  ]
  
  has_many   :users,                :dependent => :destroy
  has_one    :admin,                :class_name => "User", :conditions => { :admin => true }
  has_one    :subscription,         :dependent => :destroy
  has_many   :subscription_payments
  has_many   :offers,               :dependent => :delete_all
  has_one    :last_phone,           :class_name => "Phone", :foreign_key => "last_account_id", :dependent => :nullify
  belongs_to :current_offer,        :class_name => "Offer", :foreign_key => "offer_id"
  has_many   :session_messages,     :dependent => :delete_all,
                                    :after_add => Proc.new { |account, msg| account.increment!(:session_message_count) unless msg.kind == SessionMessage::KIND_CONFIRMATION }
  has_many   :session_emails,       :dependent => :delete_all
  has_many   :marketing_messages,   :dependent => :delete_all,
                                    :after_add => Proc.new { |account, msg| account.increment!(:marketing_message_count, msg.parts * msg.recipients) }
  has_many   :admin_messages,       :dependent => :delete_all,
                                    :after_add => Proc.new { |account, msg| account.increment!(:admin_message_count) }
  has_many   :locations,            :dependent => :destroy
  has_many   :subscribers,          :dependent => :destroy # :destroy is important for the subscribers_count updates
  has_one    :reference,            :dependent => :nullify
  has_one    :affiliate,            :dependent => :nullify, :through => :reference
  
  validates_presence_of :venue_type_other, :if => Proc.new { |account| account.venue_type == "Other" }
  validates_format_of :domain, :with => /\A[a-zA-Z0-9\-]+\Z/
  validates_exclusion_of :domain, :in => %W( support blog www billing help api #{AppConfig['admin_subdomain']} ), :message => "The domain <strong>{{value}}</strong> is not available."
  validate :valid_domain?
  validate_on_create :valid_user?
  validate_on_create :valid_plan?
  validate_on_create :valid_payment_info?
  validate_on_create :valid_subscription?
  validate_on_create :accepted_tos?
  
  attr_accessible :name, :domain, :user, :plan, :plan_start, :creditcard, :address,
                  :venue_name, :venue_address, :venue_type, :venue_type_other,
                  :conf_message, :conf_prepend_venue, :page_message, :page_prepend_venue, :offer_id, :page_append_sub,
                  :locally_registered, :tos
  attr_accessor :user, :plan, :plan_start, :creditcard, :address
  attr_accessor :tos
  
  before_validation_on_create :set_default_messages
  after_create  :create_admin
  after_create  :send_welcome_email
  
  acts_as_paranoid
  
  Limits = {
    'user_limit' => Proc.new { |a| a.users_count }
  }
  
  Limits.each do |name, meth|
    define_method("reached_#{name}?") do
      return false unless self.subscription
      val = meth.call(self)
      self.subscription.send(name) && self.subscription.send(name) <= val
    end
  end
  
  # Returns the number of users
  def users_count
    self.users.count
  end
  
  def needs_payment_info?
    if new_record?
      AppConfig['require_payment_info_for_trials'] && @plan && @plan.amount.to_f + @plan.setup_amount.to_f > 0
    else
      self.subscription.needs_payment_info?
    end
  end
  
  # Does the account qualify for a particular subscription plan
  # based on the plan's limits
  def qualifies_for?(plan)
    Subscription::Limits.keys.collect {|rule| rule.call(self, plan) }.all?
  end
  
  def active?
    self.subscription.next_renewal_at >= Time.now
  end
  
  def domain
    @domain ||= self.full_domain.blank? ? '' : self.full_domain.split('.').first
  end
  
  def domain=(domain)
    @domain = domain
    self.full_domain = "#{domain}.#{AppConfig['base_domain']}"
  end
  
  def to_s
    name.blank? ? full_domain : "#{name} (#{full_domain})"
  end
  
  def ssl_allowed?
    subscription && subscription.ssl_allowed?
  end
  
  # Returns usage
  def usage
    session_message_count.to_i + admin_message_count.to_i + marketing_message_count.to_i
  end
  
  # Returns the overuse
  def overuse
    [usage - subscription.prepaid_message_count, 0].max
  end
  
  # Reset usage
  def reset_usage
    # We intentionally decrement counters instead of setting just 0 to
    # account for any messages during our billing processing
    Account.update_counters id,
      :session_message_count    => -session_message_count.to_i,
      :admin_message_count      => -admin_message_count.to_i,
      :marketing_message_count  => -marketing_message_count.to_i
  end
  
  # Returns true if the account is incomplete
  def incomplete?
    venue_name.blank? && venue_address.blank?
  end
    
  protected
  
  def valid_domain?
    conditions = new_record? ? ['full_domain = ?', self.full_domain] : ['full_domain = ? and id <> ?', self.full_domain, self.id]
    self.errors.add(:domain, 'is not available') if self.full_domain.blank? || self.class.count(:conditions => conditions) > 0
  end
  
  # An account must have an associated user to be the administrator
  def valid_user?
    if !@user
      errors.add_to_base("Missing user information")
    elsif !@user.valid?
      @user.errors.full_messages.each do |err|
        errors.add_to_base(err)
      end
    end
  end
  
  def valid_payment_info?
    if needs_payment_info?
      unless @creditcard && @creditcard.valid?
        errors.add_to_base("Invalid payment information")
      end
      
      unless @address && @address.valid?
        errors.add_to_base("Invalid address")
      end
    end
  end
  
  def valid_plan?
    errors.add_to_base("Invalid plan selected.") unless @plan
  end
  
  def valid_subscription?
    return if errors.any? # Don't bother with a subscription if there are errors already
    self.build_subscription(:plan => @plan, :next_renewal_at => @plan_start, :creditcard => @creditcard, :address => @address)
    if !subscription.valid?
      errors.add_to_base("Error with payment: #{subscription.errors.full_messages.to_sentence}")
      return false
    end
  end
  
  def accepted_tos?
    errors.add_to_base("Please agree to our Terms of Service, Privacy and Refund policies to continue") unless @tos == '1'
  end
  
  def create_admin
    self.user.admin = true
    self.user.account = self
    self.user.save
  end
  
  def send_welcome_email
    SubscriptionNotifier.deliver_welcome(self)
  end

  private
  
  # Returns the message body
  def build_message(body, prepend_venue, add_offer = false, add_footer = true, location = nil)
    msg = ""

    # Venue name
    loc_name = location.nil? ? venue_name : location.name
    msg += "#{loc_name}:" if prepend_venue && !venue_name.blank?
    
    # Body
    unless body.blank?
      msg += " " unless msg.blank?
      msg += body
    end

    # Offer
    if add_offer && current_offer && !current_offer.text.blank?
      msg += "\n" unless msg.blank?
      msg += current_offer.text
    end

    # Instructions
    if add_footer
      msg += "\n" unless msg.blank?
      msg += STANDARD_FOOTER
    end
    
    return msg
  end

  # Sets default messages and options
  def set_default_messages
    self.conf_message     ||= DEFAULT_CONF_MESSAGE
    self.conf_prepend_venue = true
    
    self.page_message     ||= DEFAULT_PAGE_MESSAGE
    self.page_prepend_venue = true
    self.page_append_sub    = true
  end
  
end
