# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include SslRequirement
  include SubscriptionSystem
  
  helper :all # include all helpers, all the time
  
  before_filter :set_selected_tab
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '779a6e2f0fe7736f0a73da4a7d9f13d4'
  
  # Allow SSL only logged in with SSL plan feature
  def ssl_allowed?
    admin_subdomain? #|| (logged_in? && current_account.ssl_allowed?)
  end

  # Override by custom setters
  def set_selected_tab
  end
  
  # Sets the active tab
  def selected_tab=(tab_id)
    @selected_tab = tab_id.to_s
  end


  private
  
  # Renders CSV with correct headers and the file name
  def render_csv(csv, filename = nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    end

    render :layout => false, :text => csv
  end

  def get_waitlist
    if current_user && current_user.location
      @waitlist = current_user.location.waitlist || current_user.location.create_waitlist
    else
      render :template => 'guests/missing_location'
    end
  end
end
