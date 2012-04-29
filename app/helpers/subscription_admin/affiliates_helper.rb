module SubscriptionAdmin::AffiliatesHelper
  def affiliates_payouts_csv(params)
    payouts_admin_affiliates_path({
        :format => :csv,
        :type => params[:type],
        :start_date => params[:start_date],
        :end_date => params[:end_date]})
  end
end
