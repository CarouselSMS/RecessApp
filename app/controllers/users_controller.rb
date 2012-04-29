class UsersController < ApplicationController
  include ModelControllerMethods
  
  before_filter :check_user_limit, :only => :create
  
  protected
  
  def scoper
    current_account.users
  end
  
  def authorized?
    (logged_in? && self.action_name == 'index') || admin?
  end
  
  def check_user_limit
    redirect_to new_user_url if current_account.reached_user_limit?
  end

  # Sets the tab
  def set_selected_tab
    self.selected_tab = :account
  end

end
