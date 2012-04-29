class Offer < ActiveRecord::Base

  belongs_to            :account
  
  validates_presence_of :account_id
  validates_presence_of :name
  validates_presence_of :text
  validates_length_of   :text, :within => 0..30
  
  validates_length_of   :details, :within => 0..160, :allow_nil => true
  
end
