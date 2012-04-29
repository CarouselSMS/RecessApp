class MarketingMessage < ActiveRecord::Base

  KIND_OFFER_DETAILS  = 1
  KIND_MANUAL         = 2
  
  KINDS = [ KIND_OFFER_DETAILS, KIND_MANUAL ]
  
  belongs_to :account

  validates_presence_of   :account_id
  validates_presence_of   :kind
  validates_inclusion_of  :kind, :in => KINDS, :allow_blank => true

  before_create :calculate_total

  # Only manually sent messages
  named_scope :manual, :conditions => { :kind => KIND_MANUAL }

  reports_as_sparkline :complete, :grouping => :day, :value_column => :total, :aggregation => :sum, :live_data => true

  private

  # Calculates the total number of messages
  def calculate_total
    self.total = self.parts * self.recipients
  end
  
end
