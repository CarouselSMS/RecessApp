class Location < ActiveRecord::Base

  belongs_to            :account
  has_many              :session_messages,  :dependent => :nullify
  has_many              :session_emails,    :dependent => :nullify

  validates_presence_of :account_id
  validates_presence_of :name

  has_one :waitlist
end
