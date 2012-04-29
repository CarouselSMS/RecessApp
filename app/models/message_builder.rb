class MessageBuilder

  CONF_WITH_OFFER     = "Txt M for more, "
  CONF_SUFFIX         = "HELP for help\nMsg&data rates may apply\nBy recessapp.com"
  PAGE_SUFFIX         = "Waitlist alerts by recessapp.com"
  PAGE_WITH_OFFER     = "Txt M for more\n"
  SUB_WORDING         = "Reply SUB for special offers!"

  MAX_VENUE_NAME_SIZE = 20 # venue name
  MAX_OFFER_SIZE      = 30 # offer teaser
  MAX_CONF_BODY_SIZE  = 40 # confirmation message body
  MAX_PAGE_BODY_SIZE  = 40 # page message body
  
  # Confirmation message for the given account
  def self.confirmation(account, location = nil)
    prefix  = ""
    suffix  = ""
    msg     = ""
    
    if account.conf_prepend_venue
      prefix += venue_name(account, location)
      prefix += ":" unless prefix.blank?
    end
    
    unless account.conf_message.blank?
      msg += " " unless prefix.blank?
      msg += account.conf_message.to_s
    end
    
    unless account.current_offer.nil?
      suffix += "\n" unless prefix.blank? && msg.blank?
      suffix += account.current_offer.text.to_s[0, MAX_OFFER_SIZE]
    end
    
    suffix += "\n" unless prefix.blank? && suffix.blank? && msg.blank?
    suffix += CONF_WITH_OFFER unless account.current_offer.nil?
    suffix += CONF_SUFFIX
    
    body_limit = 160 - gsm_length(prefix) - gsm_length(suffix)
    
    return prefix + gsm_trim(msg, body_limit) + suffix
  end

  # Returns the length of the GSM-encoded equivalent of the string
  def self.gsm_length(str)
    str.nil? ? 0 : str.length + str.count('\^{}\[]~€|')
  end
  
  # Trims the string considering GSM-encoding
  def self.gsm_trim(str, limit)
    return nil if str.nil?
    gsm_str = str.gsub(/([\[\]\{\}\|\^\\~€])/, "\0\\0")
    return gsm_str[0, limit].gsub("\0", '')
  end
  
  # Confirmation message (free version)
  def self.free_confirmation
    "This message is to confirm addition to the waitlist.\n" +
    "Msg&data rates may apply\n" +
    "By recessapp.com"
  end
  
  # Page message (free version)
  def self.free_page
    "This is the page. You should change these in your account :)\n" +
    "Waitlist offers by recessapp.com"
  end
  
  # Confirmation message (email version)
  def self.confirmation_email(account, location = nil)
    msg = ""
    
    if account.conf_prepend_venue
      msg += venue_name(account, location)
      msg += ":" unless msg.blank?
    end

    unless account.conf_message.blank?
      msg += " " unless msg.blank?
      msg += account.conf_message
    end
    
    unless account.current_offer.nil?
      msg += "\n" unless msg.blank?
      msg += account.current_offer.details
    end
    
    return msg
  end
  
  # Page for the given account / location
  def self.page(account, location = nil)
    prefix = ""
    msg    = ""
    suffix = ""

    if account.page_prepend_venue
      prefix += venue_name(account, location)
      prefix += ":" unless prefix.blank?
    end

    unless account.page_message.blank?
      msg += " " unless prefix.blank?
      msg += account.page_message.to_s
    end
    
    if account.page_append_sub?
      suffix += "\n" unless prefix.blank? && msg.blank?
      suffix += SUB_WORDING
    end
    
    suffix += "\n" unless prefix.blank? && msg.blank? && suffix.blank?
    suffix += PAGE_WITH_OFFER unless account.current_offer.nil?
    suffix += PAGE_SUFFIX
    
    body_limit = 160 - gsm_length(prefix) - gsm_length(suffix)
    
    return prefix + gsm_trim(msg, body_limit) + suffix
  end
  
  # Page (email version) for the given account / location
  def self.page_email(account, location = nil)
    msg = ""
    
    if account.page_prepend_venue
      msg += venue_name(account, location)
      msg += ":" unless msg.blank?
    end

    unless account.page_message.blank?
      msg += " " unless msg.blank?
      msg += account.page_message
    end
    
    return msg
  end
  
  # Help message
  def self.help(account)
    prefix = account.nil? ? "W" : "#{venue_name(account)} w"
    return "#{prefix}aitlist alerts by Recess.\n" +
      "More: recessapp.com, support@recessapp.com\n" +
      "Txt STOP to end. Msg&data rates may apply."
  end
  
  # Subscription confirmation message
  def self.subscription_confirmation(account)
    "Subscribed to #{venue_name(account)} special offers, by recessapp.com.\n" +
    "Msg&data rates may apply\n" +
    "Txt STOP to end, HELP for help.\n" +
    "Under 5 msgs/wk\n" +
    "T&Cs: recessapp.com"
  end
  
  # STOP confirmation
  def self.stop_confirmation(venues)
    "Opted out of #{venues}\n" +
    "Visit recessapp.com for more\n" +
    "Txt HELP for info\n" +
    "Msg&data rates may apply"
  end
  
  # Opt-out menu
  def self.optout_menu(venues)
    menu, letter = [], "0"
    venues.each do |v|
      menu << "#{letter} for #{v}"
      letter.next!
    end
    
    return "To opt out, reply:\n" +
      menu.join("\n") +
      "\nOr STOP ALL for all"
  end

  private
  
  # Returns normalized account venue name
  def self.venue_name(account, location = nil)
    name = location.nil? ? account.venue_name : location.name
    return name.to_s[0, MAX_VENUE_NAME_SIZE]
  end
end
