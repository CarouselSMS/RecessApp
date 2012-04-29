class SubscribersController < ApplicationController

  PER_PAGE = 50

  # Front page that lists the number of subscribers
  def index
    @message_count = current_account.marketing_messages.manual.count
  end
  
  # Shows the paginated message log
  def message_log
    @messages = current_account.marketing_messages.manual.paginate({
      :page     => params[:page], 
      :per_page => PER_PAGE, 
      :order    => "created_at DESC" })
  end
  
  # Sends the marketing message to subscribers
  def send_message
    subscribers = current_account.subscribers.all(:include => :phone)
    numbers     = subscribers.map { |s| s.phone.number }
    message     = params[:message][:body].to_s.strip
    parts       = (message.length / 160.0).ceil
    recipients  = numbers.size

    unless recipients == 0 || message.blank?
      # Record delivery
      current_account.marketing_messages.create!({
        :kind       => MarketingMessage::KIND_MANUAL,
        :body       => message,
        :parts      => parts,
        :recipients => recipients
      })
      
      flash[:notice] = "Sending the message with #{parts} part(s) to #{recipients} subscriber(s)"
      
      spawn do
        logger.info "Sending manual subscription message to #{recipients} subscribers: domain=#{current_account.domain}, parts=#{parts}"
        ServiceLayer.new.send_messages(numbers, message)
        logger.info "Finished sending"
      end
    else
      flash[:notice] = "You have no subscribers or the message is blank"
    end

    redirect_to subscribers_url
  end

  # Sets the tab
  def set_selected_tab
    self.selected_tab = :subscribers
  end

end
