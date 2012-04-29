class Iphone < ActiveRecord::Base

  MAX_FREE = 250

  validates_presence_of   :udid
  validates_length_of     :udid, :is => 40
  validates_uniqueness_of :udid
  
  validates_presence_of   :sent
  
  # Returns TRUE if this phone can send more free messages
  def can_send_free_messages?
    !blocked? && sent < MAX_FREE
  end
  
end
