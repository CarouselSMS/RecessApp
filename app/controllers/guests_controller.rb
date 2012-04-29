class GuestsController < ApplicationController
  before_filter :get_waitlist
  before_filter :get_guest, :only => [:page, :arrive, :noshow, :waiting, :destroy]
  layout "application", :except => [:webapp_popup]

  def webapp_popup
  end

  def show
    if params[:id] == 'undefined'
      render :nothing => true 
    else
      @guest = Guest.find(params[:id])
      render :partial => 'guests/details', :layout => false
    end
  end

  def index
  end

  def create
    @guest = @waitlist.guests.new(params[:guest])
    if @guest.save
      @guest.send_confirmation!(current_account)
      refresh_waitlist
    else
      render_error('invalid')
    end
  end

  def destroy
    @guest.delete
    refresh_waitlist('Removed Successfully', true)
  end

  def clear
    @waitlist.guests.delete_all
    refresh_waitlist
  end

  def waiting_list
    @guests = @waitlist.guests.waiting
    switch_waitlist('Waiting')
  end

  def paged_list
    @guests = @waitlist.guests.paged
    switch_waitlist('Paged')
  end

  def arrived_list
    @guests = @waitlist.guests.arrived
    switch_waitlist('Arrived')
  end

  def noshow_list
    @guests = @waitlist.guests.noshow
    switch_waitlist('No-Show')
  end

  def all
    @active_guest_id = params[:guest_id]
    case params[:type]
    when 'waiting_list'
      @guests = @waitlist.guests.waiting
      state = 'Waiting'
    when 'paged_list'
      @guests = @waitlist.guests.paged
      state = 'Paged'
    when 'arrived_list'
      @guests = @waitlist.guests.arrived
      state = 'Arrived'
    when 'noshow_list'
      @guests = @waitlist.guests.noshow
      state = 'No-Show'
    else
      @guests = @waitlist.guests
      state = 'All'
    end
    if state == 'All'
      partial = 'guests/guest_list'
    else
      partial = 'guests/list'
    end
    @guest = Guest.find(params[:guest_id]) unless params[:guest_id].blank? || params[:guest_id] == 'undefined'
    if params[:poll] == 'true'
      render :update do |page|
        page.replace_html 'guest-list', :partial => partial, :locals => { :state => state }
        page.call 'refresh_dom'
        page.replace_html 'guest-details', :partial => 'guests/details'
      end
    else
      render :partial => 'guests/guest_list', :layout => false, :locals => { :state => state }
    end
  end

  def page
    @guest.send_page!(current_account)
    refresh_waitlist('Page sent')
    rescue
      render_error('details-message')
  end

  def arrive
    @guest.arrive!
    refresh_waitlist
    rescue
      render_error('details-message')
  end

  def noshow
    @guest.absent!
    refresh_waitlist
    rescue
      render_error('details-message')
  end

  def waiting
    @guest.send_to_waiting!
    refresh_waitlist
    rescue
      render_error('details-message')
  end

  private

  def get_guest
    @guest = @waitlist.guests.find(params[:id])
  end

  def refresh_waitlist(message=nil, delete=false)
    res = @guest.nil? ? '' : { :partial => 'guests/details' }
    render :update do |page|
      page.replace_html 'guest-list', :partial => 'guests/guest_list'
      page.replace_html 'guest-details', (delete ? '' : res)
      page.replace_html 'details-message', "<h3 class='notice'>#{ message }</h3>" if message
      page.call "$('div.flash').hide"
      page.call "$('#details-message').show" if message
      page.call "$('#guest-form').reset"
      page.call "$('ul.waitlistButtons li a').removeClass", 'active'
      page.call "$('a#all').addClass", 'active'
      page.call "refresh_dom"
    end
  end

  def switch_waitlist(state)
    render :partial => 'guests/list', :layout => false, :locals => { :state => state }
  end

  def render_error(div)
    render :update do |page|
      page.call "$('##{ div }').show"
    end
  end

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
end