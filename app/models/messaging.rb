class Messaging

  # Initializes the messaging service for the given account
  def initialize(account = nil, registration_account = nil)
    @account = account
    @registration_account = registration_account || account
  end
  
  # Sends the confirmation
  def send_confirmation(phone_number, location_id = nil)
    send_and_register(phone_number, location_id, :confirmation, SessionMessage::KIND_CONFIRMATION)
  end
  
  # Sends the page
  def send_page(phone_number, location_id = nil)
    send_and_register(phone_number, location_id, :page, SessionMessage::KIND_PAGE)
  end

  # Sends a free confirmation to the phone
  def send_free_confirmation(phone_number, iphone)
    service_layer.send_message(phone_number, MessageBuilder::free_confirmation, false)
    iphone.increment!(:sent)
  end
  
  # Sends a free page to the phone
  def send_free_page(phone_number, iphone)
    service_layer.send_message(phone_number, MessageBuilder::free_page, false)
    iphone.increment!(:sent)
  end
  
  # Sends the confirmation over email
  def send_confirmation_email(email, location_id = nil)
    location = find_location(location_id)
    CustomerNotifier.deliver_confirmation(email, @account, location)
    register_session_email(SessionEmail::KIND_CONFIRMATION, email, location)
  end

  # Sends the page over email
  def send_page_email(email, location_id = nil)
    location = find_location(location_id)
    CustomerNotifier.deliver_page(email, @account, location)
    register_session_email(SessionEmail::KIND_PAGE, email, location)
  end
  
  private
  
  # Creates the instance of a service layer
  def service_layer
    @sl ||= ServiceLayer.new
  end

  # Registers the phone number of finds it
  def register_phone_number(phone_number, options = {})
    phone = Phone.find_or_create_by_number(phone_number)
    phone.update_attribute(:last_account_id, @registration_account.id) if options[:set_last_account]
    return phone
  end

  # Finds the location
  def find_location(location_id)
    location_id.nil? ? nil : @registration_account.locations.find(location_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end
  
  # Registers the session message in log
  def register_session_message(kind, phone, location = nil, dlr_message_id = nil)
    @registration_account.session_messages.create!(:kind => kind, :phone => phone, :location => location, :dlr_message_id => dlr_message_id)
  end
  
  # Registers the session message over email
  def register_session_email(kind, email, location = nil)
    @registration_account.session_emails.create!(:kind => kind, :email => email, :location => location)
  end

  # Sends a message and registers it
  def send_and_register(phone_number, location_id, type, kind)
    phone     = register_phone_number(phone_number, :set_last_account => true)
    location  = find_location(location_id)

    response  = service_layer.send_message(phone_number, MessageBuilder.send(type, @account, location))
    if response && response.kind_of?(Hash)
      dlr_message_id = response["message_ids"].to_s.split(',')
      dlr_message_id = dlr_message_id.first
    end
    
    register_session_message(kind, phone, location, dlr_message_id)
  end
end
