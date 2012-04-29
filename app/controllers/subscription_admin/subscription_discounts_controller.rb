class SubscriptionAdmin::SubscriptionDiscountsController < ApplicationController
  include ModelControllerMethods
  include AdminControllerMethods

  private
  
  # Sets the tab
  def set_selected_tab
    self.selected_tab = :discounts
  end
  
end
