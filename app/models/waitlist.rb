class Waitlist < ActiveRecord::Base
  belongs_to :location
  has_many :guests

  validates_presence_of :location_id
end
