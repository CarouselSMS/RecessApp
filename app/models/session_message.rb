class SessionMessage < ActiveRecord::Base

  KIND_CONFIRMATION = 1
  KIND_PAGE         = 2
  
  KINDS = [ KIND_CONFIRMATION, KIND_PAGE ]
  
  belongs_to :account
  belongs_to :phone
  belongs_to :location

  validates_presence_of   :account_id
  validates_presence_of   :phone_id
  validates_presence_of   :kind
  validates_inclusion_of  :kind, :in => KINDS, :allow_blank => true
  
  reports_as_sparkline    :complete, :grouping => :day, :live_data => true
  
end
