class ApiController < ApplicationController

  skip_before_filter  :set_selected_tab

  # Disable CSRF
  skip_before_filter  :verify_authenticity_token
  
  # Skip login for free message versions
  skip_before_filter  :login_required,    :only => [ :send_free_confirmation, :send_free_page ]

  before_filter       :iphone_required,   :only => [ :send_free_confirmation, :send_free_page ]
  before_filter       :block_if_on_hold,  :only => [ :send_confirmation, :send_page ]

  rescue_from         StandardError, :with => :render_error

  # Returns various account-related details:
  # account itself, registered locations, offers, usage, messages.
  # The client can choose which fields to include by specifying
  # the comma-separated list of sections.
  def info
    kind = (params[:kind] || "account,locations,offers,usage,messages").split(/\s*,\s*/)
    
    info = {}

    # General account info
    if kind.include?("account")
      info[:account] = {
        :domain           => current_account.full_domain,
        :venue_name       => current_account.venue_name, 
        :venue_address    => current_account.venue_address, 
        :venue_type       => current_account.venue_type, 
        :venue_type_other => current_account.venue_type_other,
        :on_hold          => current_account.on_hold
      }
    end
    
    # Offers
    if kind.include?("offers")
      info[:offers] = current_account.offers.map do |o|
        { :id       => o.id,
          :name     => o.name,
          :text     => o.text,
          :details  => o.details }
      end
    end
    
    # Message format
    if kind.include?("messages")
      info[:messages] = {
        :conf_message       => current_account.conf_message,
        :conf_prepend_venue => current_account.conf_prepend_venue,
        :page_message       => current_account.page_message,
        :page_prepend_venue => current_account.page_prepend_venue,
        :offer_id           => current_account.offer_id
      }
    end
    
    if kind.include?("locations")
      info[:locations] = current_account.locations.map do |l|
        { :id           => l.id,
          :name         => l.name,
          :internal_id  => l.internal_id }
      end
    end
    
    if kind.include?("usage")
      info[:usage] = usage_info
    end
    
    render :text => info.to_json
  end
  
  # -----------------------------------------------------------------------------------------------
  # Offers
  # -----------------------------------------------------------------------------------------------
  
  # Creates a new offer
  def create_offer
  end
  
  # Updates the offer
  def update_offer
  end
  
  # Deletes the offer
  def delete_offer
  end
  
  # -----------------------------------------------------------------------------------------------
  # Messaging
  # -----------------------------------------------------------------------------------------------
  
  # Updates the messages of the account
  def update_messages
    p = sanitize(params[:messages], [
      "conf_message", "conf_prepend_venue", "page_message", "page_prepend_venue", "offer_id" ])

    if current_account.update_attributes(p)
      render :text => ""
    else
      raise current_account.errors.full_messages.to_json
    end
  end

  # Sends the confirmation message to a phone
  def send_confirmation
    send_message("confirmation")
  end
  
  # Sends the page to a phone
  def send_page
    send_message("page")
  end

  # Sends a free version of the confirmation message
  # @iphone is initialized by :iphone_required
  def send_free_confirmation
    send_free_message("confirmation")
  end
  
  # Sends a free version of the page message
  # @iphone is initialized by :iphone_required
  def send_free_page
    send_free_message("page")
  end
  
  # Requests the delivery report for the messages
  def delivery_report
    msgid = params[:message_ids].to_s.split(",")
    messages = SessionMessage.all(:conditions => { :id => msgid })

    result   = {}
    messages.each { |m| result[m.id] = { :status => m.dlr_status, :final => m.dlr_final } }

    render :text => result.to_json
  end
  
  private
  
  # Returns the hash with usage info
  def usage_info
    { :session_messages   => current_account.session_message_count.to_i,
      :marketing_messages => current_account.marketing_message_count.to_i,
      :prepaid_messages   => current_account.subscription.prepaid_message_count.to_i }
  end
  
  # Creates a new hash with only allowed keys
  def sanitize(p, keys)
    new_params = {}
    keys.each { |k| new_params[k] = p[k] if p.include?(k) }
    return new_params.symbolize_keys
  end

  # Normalizes the phone number
  def normalize_phone(phone_number)
    raise "Phone number is blank" if phone_number.blank?
    raise "Invalid phone number" unless /^\+?1?\d{10}$/ =~ phone_number.strip
    SmsToolkit::PhoneNumbers.normalize(phone_number)
  end
  
  # Normalizes the e-mail address
  def normalize_email(email)
    raise "E-mail address is blank" if email.blank?
    raise "Invalid e-mail address" unless Authentication.email_regex =~ email
    email.strip
  end
  
  # Sends a message to phone and / or email when given
  def send_message(kind, phone_number = params[:phone_number], email = params[:email], location_id = nil)
    raise "Neither email nor phone_number were given" if phone_number.blank? && email.blank?

    # If the location isn't mentioned explicitly, use the one this user is assigned to
    location_id ||= choose_location
    
    result = { }
    
    # Send message and / or e-mails
    messaging = Messaging.new(current_account)
    unless phone_number.blank?
      session_message = messaging.send("send_#{kind}", normalize_phone(phone_number), location_id)
      result[:message_id] = session_message.id
    end
    messaging.send("send_#{kind}_email", normalize_email(email), location_id) unless email.blank?

    # Add usage info
    result[:usage] = usage_info
    
    render :text => result.to_json
  end
  
  # Chooses location for the message
  def choose_location
    params[:location_id] || current_user.location_id
  end
  
  # Sends a free message to phone
  def send_free_message(kind, phone_number = params[:phone_number])
    raise "Phone_number is not given" if phone_number.blank?
    
    messaging = Messaging.new
    messaging.send("send_free_#{kind}", normalize_phone(phone_number), @iphone)
    
    render :text => ""
  end
  
  # Renders an error
  def render_error(exception)
    logger.error(exception.message + "\n" + exception.backtrace.join("\n"))
    render :text => exception.message, :status => 500
  end
  
  # Blocks access to on-hold accounts
  def block_if_on_hold
    raise "Account is currently on hold. Messaging is disabled." if current_account.on_hold?
  end
  
  # Checks if the iphone is allowed to send free messages
  def iphone_required(udid = params[:udid])
    udid = udid.to_s.strip
    
    raise "IPhone UDID isn't given" if udid.blank?
    raise "IPhone UDID is invalid" unless /^[0-9a-f]{40}$/i =~ udid
    
    @iphone = Iphone.find_or_create_by_udid(udid)

    raise "IPhone is not allowed to send free messages" unless @iphone.can_send_free_messages?
  end
  
  # -----------------------------------------------------------------------------------------------
  # Custom log-in processing.
  #
  # We allow users log in without using subdomain.domain.com notation, using just domain.com
  # and their U/P. The current_account is evaluated from the user account on successful
  # login.
  #
  # Caller can learn the domain from the "info" API call (see :domain key).
  # -----------------------------------------------------------------------------------------------
  
  # Logging in from session
  def login_from_session
    self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
  end

  # Logging in from basic auth
  def login_from_basic_auth
    authenticate_with_http_basic do |login, password|
      self.current_user = User.authenticate(login, password)
    end
  end

  # Logging in from cookie
  def login_from_cookie
    user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      self.current_user = user
      handle_remember_cookie! false # freshen cookie token (keeping date)
      self.current_user
    end
  end
  
  # Wrap the current_user call to set current_account
  def current_user_with_account
    user = current_user_without_account
    @current_account = user.account unless (user.nil? || user == false) || !@current_account.nil?
    return user
  end
  alias_method_chain :current_user, :account
  
end
