class UserSession < ActiveRecord::Base
  has_many :guests, :class_name => 'DemoGuest'
  validates_presence_of :session_id
  after_create :create_default_guests

  def page_count
    guests.inject(0){ |sum,g| sum+=g.page_count }
  end

  private
  def create_default_guests
    DEFAULT_GUESTS.each do |guest|
      guests.create(guest)
    end
  end
end
