class FrontController < ApplicationController

  layout "application", :except => [ :demomodal, :exitmodal, :webapp, :wufoo_offer ]

  skip_before_filter :login_required
  skip_before_filter :set_selected_tab
  
  # Shows and accepts a feedback form
  def feedback_form
    @feedback = Feedback.new(params[:feedback])
    @feedback.save if params[:feedback]
  end

  # Registers the customer coming through the partner if
  # they aren't registered yet and sends them to the pricing page.
  def remember_customer
    if cookies[AppConfig['reference_cookie_name']].nil?
      @affiliate = Affiliate.find_by_slug(params[:slug])
      unless @affiliate.nil?
        @reference = Reference.create(:affiliate_id => @affiliate.id)
        cookies[AppConfig['reference_cookie_name']] = {
          :value => @reference.cookie_token,
          :expires => AppConfig['reference_registration_span'].to_i.days.from_now
        }
      end
    end

    redirect_to :action => :pricing
  end
end
