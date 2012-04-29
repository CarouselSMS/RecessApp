class StatisticsFilter
  
  attr_accessor :from, :to, :location_id
  
  # Initializes with parameters
  def initialize(account, params = {})
    if params.nil?
      for_account(account)
    else
      @from         = to_date(params, "from")
      @to           = to_date(params, "to")
      @location_id  = params[:location_id]
      @location_id  = @location_id.to_i unless @location_id.blank?
    end
  end
  
  # Initializes for the account
  def for_account(account)
    sub           = account.subscription
    @from         = [ 1.month.ago, sub.next_renewal_at.advance(:months => -sub.renewal_period) ].max
    @to           = Time.now
    @location_id  = nil
  end
  
  # Returns the number of days in range
  def days_in_range
    return 0 if @from.nil? || @to.nil?
    ((@to - @from) / 1.day).ceil.abs
  end
  
  private
  
  # Simple filter date converter
  def to_date(params, key)
    y, m, d = params["#{key}(1i)"], params["#{key}(2i)"], params["#{key}(3i)"]
    y.nil? ? nil : Time::mktime(y, m, d)
  end
end