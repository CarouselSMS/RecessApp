class LogsController < ApplicationController

  def index
    @location = Location.find(params[:location_id])
    if @location.waitlist.nil?
      @logs = []
    else
      guest_ids = @location.waitlist.guests.map(&:id)
      @logs = Audit.paginate :conditions => ["auditable_type='Guest' AND auditable_id IN(?)", guest_ids] ,:page => params[:page], :per_page => 25, :order => 'created_at DESC'
    end
  end
end