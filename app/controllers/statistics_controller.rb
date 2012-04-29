class StatisticsController < ApplicationController

  # Shows the index page
  def index
    @filter = StatisticsFilter.new(current_account, params[:filter])

    # Search options
    conditions = { :account_id => current_account.id, :created_at => ( @filter.from .. @filter.to ) }
    conditions[:location_id] = @filter.location_id unless @filter.location_id.blank?
    
    # Report options
    options = { :limit => @filter.days_in_range, :conditions => conditions }
    
    # Don't generate this reports if location is selected
    unless conditions[:location_id]
      @admin_messages_report      = AdminMessage.complete_report(options)
      @marketing_messages_report  = MarketingMessage.complete_report(options)
    end

    # Add kind condition
    options[:conditions].merge!(:kind => SessionMessage::KIND_PAGE)
    @session_messages_report      = SessionMessage.complete_report(options)
  end
  
  # Sets the tab
  def set_selected_tab
    self.selected_tab = :statistics
  end

end
