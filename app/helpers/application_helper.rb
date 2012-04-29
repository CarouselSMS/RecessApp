# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def flash_notices
    [:notice, :error].collect {|type| content_tag('div', flash[type], :id => type) if flash[type] }
  end
  
  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes')
    content_tag(:div, submit_tag(label) + ' or ' +
      link_to('Cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit')
  end

  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, :precision => 0) : number_to_currency(discount.amount)) + ' off'
  end
  
  # Format the text as SMS
  def sms(text)
    h(text).sub("\n", "<br/>")
  end
  
  # Returns the account state summary
  def account_state(subscription)
    if subscription.state == "trial"
      return "Trial"
    else
      return subscription.on_hold? ? "On Hold" : "Active"
    end
  end
  
  def location_select(f, key = :location_id)
    f.select key, current_account.locations.map { |l| [ l.name, l.id ] }, { :include_blank => true }, :class => "location"
  end

  # Returns the base host w/ port (if necessary)
  def base_host
    port = request.port
    "http://www.#{AppConfig['base_domain']}#{(port == 80 || port == 443) ? '' : ":#{port}"}"
  end
  
  # Link to front page that knows if it's active
  def link_to_front(label, action, html_options = {}, current_action = params[:action])
    html_options[:class] = [ html_options[:class], "active" ].compact.join(" ") if current_action.to_s == action.to_s
    link_to(label, "#{base_host}" + url_for(:controller => "front", :action => action), html_options)
  end

  # Returns the link for the tab
  def tab_link_to(tab_id, label, url)
    tab_id      ||= "undefined"
    selected_tab  = @selected_tab || ""
    link_to(label, url, :class => (tab_id.to_s == selected_tab.to_s) ? "active" : nil)
  end
  
  # Link to the same page, but with page and order
  def paged_sorted_self_link(label, order, page = params[:page])
    query = []
    query << "page=#{page}" if page
    query << "sort=#{order}" if order
    return link_to(label, "?#{query.join('&')}")
  end
  
  # Link to Apple App Store, Recess
  def link_to_appstore
    link_to("Recess Paging System available in the App Store!", "http://www.itunes.com/app/RecessPagingSystem", :title => "Recess Paging System available in the App Store!", :class => "png")
  end
end
