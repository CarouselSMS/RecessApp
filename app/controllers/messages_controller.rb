require 'ostruct'

class MessagesController < ApplicationController

  # Shows messages
  def index
    @account = current_account
  end
  
  # Updates messages
  def update
    @account = current_account
    if @account.update_attributes(params[:account])
      flash[:notice] = "Messages were updated"
      redirect_to dashboard_url
    else
      render :index
    end
  end
  
  # Sends a test confirmation message
  def send_test_conf
    send_message('confirmation')
  end
  
  # Sends a test page message
  def send_test_page
    send_message('page')
  end

  # Sends a test offer
  def send_test_offer
    offer = Offer.new(params[:offer])
    phone_number = normalize_phone(params[:phone_number])
    
    offer.valid?
    raise "Details can't be empty" if offer.details.blank?
    raise "Details #{offer.errors['details']}" if !offer.errors["details"].blank?
    
    # send offer and register
    service_layer.send_message(phone_number, offer.details, false)
    MO::Handler.record_response(current_account, :marketing, offer.details)
    render :text => "Sent"
  rescue => e
    render :text => e.message
  end
  
  private
  
  # Service layer
  def service_layer
    ServiceLayer.new
  end
  
  # Send the message of a certain kind
  def send_message(kind, account = Account.new(current_account.attributes.merge(params[:account])), registration_account = current_account)
    # Send the message if the phone is given
    phone_number = params[:phone_number]
    unless phone_number.blank?
      messaging = Messaging.new(account, registration_account)
      messaging.send("send_#{kind}", normalize_phone(phone_number), current_user.location_id)
    end
  
    render :text => "Sent"
  rescue => e
    render :text => e.message
  end

  # Normalizes the phone number
  def normalize_phone(phone_number)
    raise "Phone number is blank" if phone_number.blank?
    raise "Invalid phone number" unless /^\+?1?\d{10}$/ =~ phone_number.strip
    SmsToolkit::PhoneNumbers.normalize(phone_number)
  end

  # Sets the tab
  def set_selected_tab
    self.selected_tab = :messages
  end
  
end
