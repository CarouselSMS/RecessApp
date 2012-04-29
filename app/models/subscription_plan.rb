class SubscriptionPlan < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  UNLIMITED = 9999
  
  has_many :subscriptions
  
  # renewal_period is the number of months to bill at a time
  # default is 1
  validates_numericality_of :renewal_period, :only_integer => true, :greater_than => 0
  validates_numericality_of :trial_period, :allow_nil => true
  validates_presence_of :name
  
  attr_accessor :discount

  def to_s
    "#{self.name} - #{number_to_currency(self.amount)} / month"
  end
  
  def to_param
    self.name
  end
  
  def amount(include_discount = true)
    include_discount && @discount && @discount.apply_to_recurring? ? self[:amount] - @discount.calculate(self[:amount]) : self[:amount]
  end
  
  def setup_amount(include_discount = true)
    include_discount && setup_amount? && @discount && @discount.apply_to_setup? ? self[:setup_amount] - @discount.calculate(self[:setup_amount]) : self[:setup_amount]
  end
  
  def trial_period(include_discount = true)
    include_discount && @discount ? self[:trial_period] + (@discount.trial_period_extension || 0) : self[:trial_period]
  end
  
  def overusage_price
    0.07
  end
  
  def revenues
    @revenues ||= subscriptions.calculate(:sum, :amount, :group => 'subscriptions.state')
  end

  # Returns the date / time of the first billing
  def first_billing_at
    time = Time.now
    time = time.advance(:days => trial_period) if trial_period?
    return time
  end
  
  # Returns the description of the plan
  def description
    return @description if @description
    
    parts = []
    
    tp = trial_period(false)
    parts << "#{tp}-day trial" if tp && tp > 0
    
    sa = setup_amount(false)
    parts << "#{number_to_currency(sa)} setup fee" if sa && sa > 0
    
    am = amount(false)
    parts << "#{number_to_currency(am)}/mo"
    
    if prepaid_message_count >= UNLIMITED
      texts = "unlimited"
    else
      texts = "#{prepaid_message_count}/mo prepaid"
    end
    
    @description = parts.join(', ') + " and #{texts} texts after that."

    return @description
  end
  
end
