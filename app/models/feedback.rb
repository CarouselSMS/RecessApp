class Feedback < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :email

end
