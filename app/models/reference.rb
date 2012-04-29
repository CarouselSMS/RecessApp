class Reference < ActiveRecord::Base
  belongs_to :affiliate, :counter_cache => true
  belongs_to :account

  validates_uniqueness_of :cookie_token

  before_create :generate_cookie_token

  class << self
    def stats(start_time = nil, end_time = nil)
      start_time  = to_time(start_time) rescue Time.now.at_beginning_of_month
      end_time    = to_time(end_time).end_of_day rescue Time.now

      all(
        :conditions => {:registered_at => (start_time..end_time)},
        :include => [:account, :affiliate],
        :order => 'references.registered_at ASC')
    end

    
    private

    def to_time(arg)
      arg = Time.parse(arg) unless arg.respond_to?(:to_time)
      return arg.to_time
    end
  end



  private

  def generate_cookie_token
    begin
      self.cookie_token = Digest::SHA1.hexdigest(Time.now.to_f.to_s + rand(1000000).to_s)
    end while Reference.find_by_cookie_token(cookie_token)
  end
  
end
