class Subscriber < ActiveRecord::Base

  belongs_to :account, :counter_cache => true
  belongs_to :phone

  validates_presence_of   :account_id
  validates_presence_of   :phone_id
  validates_uniqueness_of :phone_id, :scope => [ :account_id ]

  before_create :set_next_renewal_at
  
  private
  
  # Sets the renewal date ahead
  def set_next_renewal_at
    self.next_renewal_at = Time.now.advance(:months => 1)
  end
  
end
