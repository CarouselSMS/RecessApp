class MO::Handler
  
  # Processes the MO and returns what to send back
  def self.process(phone_number, body)
    phone = Phone.find_by_number(phone_number, :include => :last_account)
    return nil if phone.nil?
    
    response, kind = get_response(phone, body)
    record_response(phone.last_account, kind, response)

    return response
  end
  
  # Loggs the response if necessary.
  def self.record_response(account, kind, body = nil)
    return if kind.nil? || account.nil?
  
    case kind
    when :admin
      account.admin_messages.create!
    when :marketing
      account.marketing_messages.create!({
        :kind   => MarketingMessage::KIND_OFFER_DETAILS,
        :body   => body,
        :parts  => (body.to_s.length / 160.0).ceil })
    end
  end

  private
  
  # Analyzes the message and returns an appropriate response and message kind for
  # proper bucketing. If message is not to be sent, both are nil. If message is to
  # be sent but not logged, the kind is nil. Otherwise both are set.
  def self.get_response(phone, body)
    # Normalize body (stripped uppercase)
    body = body.to_s.strip.upcase

    res, kind = process_opt_out(phone, body)
    
    unless res == false
      return res, kind
    else
      # Last account this phone was talking to
      last_account = phone.last_account
    
      case body
      when /^M(ORE)?$/
        if last_account.nil?
          log phone.number, "MORE: No link to any account"
          return nil
        elsif last_account.current_offer.nil?
          log phone.number, "MORE: No current offer at #{last_account.domain}"
          return nil
        else
          msg = last_account.current_offer.details
          log phone.number, "MORE: Sent offer #{last_account.current_offer.name}"
          return msg, :marketing
        end

      when /^HELP/
        return MessageBuilder::help(last_account), :admin
      
      when /^SUB(SCRIBE)?/
        if last_account.nil?
          log phone.number, "SUB: No link to account"
          return nil
        else
          # Allow continuous subscription (#147), just say in log so
          if last_account.subscribers.map(&:phone_id).include?(phone.id)
            log phone.number, "SUB: Already subscribed to #{last_account.domain}"
          else
            last_account.subscribers.create!(:phone => phone)
            log phone.number, "SUB: Subscribed to #{last_account.domain}"
          end

          return MessageBuilder::subscription_confirmation(last_account), :admin
        end
    
      when /^STOP$/
        subs = phone.subscriptions
        if subs.empty?
          log phone.number, "STOP: Nothing to unsubscribe from"
          return nil
        elsif subs.size == 1
          venue = subs.first.account.venue_name
          phone.subscriptions.clear
          log phone.number, "STOP: Ubsubscribed from #{venue}"
          return MessageBuilder::stop_confirmation(venue), :admin
        else
          phone.start_optout

          venues = subs.sort_by(&:id).map(&:account).map(&:venue_name)
          log phone.number, "STOP: Multi-optout for #{venues.inspect}"
          return MessageBuilder::optout_menu(venues), :admin
        end
      
      when /^STOP\s*ALL$/
        subs = phone.subscriptions
        if subs.empty?
          log phone.number, "STOP ALL: Nothing to unsubscribe from"
          return nil
        else
          venues = subs.map(&:account).map(&:venue_name).join(", ")
          phone.subscriptions.clear
          log phone.number, "STOP ALL: Unsubscribed from #{venues}"
          return MessageBuilder::stop_confirmation(venues), :admin
        end      
      end
    end
    
    return nil
  end
  
  # Sees if it's time to process opt-out and returns TRUE if processed, FALSE if need to go on.
  def self.process_opt_out(phone, body)

    # See if we handling the opt-out menu
    if phone.opting_out?
      begin
        if /^\d+$/ =~ body
          subs = phone.subscriptions.sort_by(&:id)
          sub  = subs[body.to_i]

          if sub.nil?
            # Wrong choice
            log phone.number, "STOP MENU: Chose missing subscription '#{body}'"
            return nil
          else
            venue = sub.account.venue_name
            sub.destroy
            log phone.number, "STOP MENU: Unsubscribed from #{venue}"
            return MessageBuilder::stop_confirmation(venue), :admin
          end
        else
          log phone.number, "STOP MENU: Not a number '#{body}'"
        end
      ensure
        phone.stop_optout
      end
    end

    return false
  end
  
  # Logs a message
  def self.log(phone_number, msg)
    ActiveRecord::Base.logger.info("#{phone_number} - #{msg}")
  end
  
end