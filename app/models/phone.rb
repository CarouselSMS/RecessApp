class Phone < ActiveRecord::Base

  belongs_to  :last_account,        :class_name => "Account"
  has_many    :session_messages,    :dependent => :nullify
  has_many    :subscriptions,       :class_name => "Subscriber", :dependent => :destroy # important for cached counters

  validates_presence_of :number

  # Put the phone into opt-out mode before the next message or 10 minutes from now
  def start_optout
    update_attribute(:optout_before, 10.minutes.from_now)
  end
  
  # Stops the opt-out process
  def stop_optout
    update_attribute(:optout_before, nil)
  end
  
  # Returns TRUE if the phone is currently in the opt-out timeframe
  def opting_out?
    optout_before && Time.now < optout_before
  end
  
end
