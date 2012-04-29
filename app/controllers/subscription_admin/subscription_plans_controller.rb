class SubscriptionAdmin::SubscriptionPlansController < ApplicationController
  include ModelControllerMethods
  include AdminControllerMethods
  
  protected
  
  def load_object
    @obj = @subscription_plan = SubscriptionPlan.find_by_name(params[:id])
  end

  # Sets the tab
  def set_selected_tab
    self.selected_tab = :plans
  end

end
