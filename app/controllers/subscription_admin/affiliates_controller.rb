class SubscriptionAdmin::AffiliatesController < ApplicationController
  include ModelControllerMethods
  include AdminControllerMethods
  include ActionView::Helpers::NumberHelper

  def index
    session[:affiliates_order] = (params[:sort].blank? ? nil : params[:sort]) if params[:sort]
    order = session[:affiliates_order] || 'last_name'
    @affiliates = Affiliate.paginate(:page => params[:page], :per_page => 30, :order => order)
  end

  def show
  end


  def monthly_stats
    load_object
    @stats = @affiliate.monthly_stats
  end


  def accounts
    load_object
  end


  def payouts
    case params[:type]
      when 'prev_month'
        params[:start_date]  = 1.month.ago.beginning_of_month
        params[:end_date]    = 1.month.ago.end_of_month
      when 'current_month'
        params[:start_date] = Time.now.beginning_of_month
        params[:end_date]   = Time.now
        params[:type]       = 'current_month'
    end

    @stats = Reference.stats(params[:start_date], params[:end_date])

    respond_to do |wants|
      wants.html
      wants.csv { render_stats_csv(@stats) }
    end
  end

  protected

  # Sets the tab
  def set_selected_tab
    self.selected_tab = :affiliates
  end

  private

  def render_stats_csv(stats)
    # - Affiliate
    # name
    # slug (code)
    # - Account
    # id
    # name
    # - Reference
    # signup date
    # payment_amount
    # subscription_amount
    # payment_percent

    csv = FasterCSV.generate do |data|
      data << [ "Affiliate Name", "Affiliate Code", "Account ID", "Account Name", "Signup Date", "Payout", "Revenue", "Percent" ]
      stats.each do |reference|

        data << [
          reference.affiliate.name,
          reference.affiliate.slug,
          reference.account.id,
          reference.account.name,
          reference.registered_at.to_s(:short_day),
          number_to_currency(reference.payment_amount),
          number_to_currency(reference.subscription_amount),
          "#{reference.payment_percent}%" ]
      end
    end

    render_csv csv, "affiliates-payouts-#{Time.now.to_s(:ymd)}"
  end
  
end
