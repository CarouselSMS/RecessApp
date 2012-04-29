class SessionEmail < ActiveRecord::Base

  KIND_CONFIRMATION = 1
  KIND_PAGE         = 2
  
  KINDS = [ KIND_CONFIRMATION, KIND_PAGE ]

  belongs_to              :account, :counter_cache => :session_email_count
  belongs_to              :location

  validates_presence_of   :account_id
  validates_presence_of   :kind
  validates_inclusion_of  :kind, :in => KINDS
  validates_presence_of   :email
  
end
