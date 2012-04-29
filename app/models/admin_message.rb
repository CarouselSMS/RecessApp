class AdminMessage < ActiveRecord::Base

  belongs_to :account

  validates_presence_of   :account_id

  reports_as_sparkline    :complete, :grouping => :day, :live_data => true

end
