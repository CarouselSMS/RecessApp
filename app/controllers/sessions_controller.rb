# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  skip_before_filter :login_required
  skip_before_filter :set_selected_tab
  before_filter :login_required_if_not_admin, :only => :destroy # admin === masteradmin

  def create
    logout_keeping_session!

    if admin_subdomain?
      create_admin_session
    else
      create_user_session
    end
  rescue ActiveRecord::RecordNotFound
    note_failed_signin
    @login       = params[:login]
    @remember_me = params[:remember_me]
    render :action => 'new'
  end

  # Invoked when a Recess admin wants to log in as another user with a temporary token
  def create_as_admin
    create
  end
  
  def destroy
    # After the session is killed this will vanish, so we take it first
    logging_out_as_admin = logging_out_as_admin?

    logout_killing_session!

    if logging_out_as_admin
      flash[:notice] = "You have been logged out from user account"
      redirect_to "http://#{AppConfig['admin_subdomain']}.#{AppConfig['base_domain']}#{admin_account_path(current_account)}"
    else
      session[:admin_is_logged_in] = nil
      flash[:notice] = "You have been logged out"
      redirect_back_or_default('/')
    end
  end

  def forgot
    return unless request.post?
    
    if !params[:email].blank? && @user = current_account.users.find_by_email(params[:email])
      PasswordReset.create(:user => @user, :remote_ip => request.remote_ip)
      render :action => 'forgot_complete'
    else
      flash[:error] = "That account wasn't found."
    end
  end
  
  def reset
    raise ActiveRecord::RecordNotFound unless @password_reset = PasswordReset.find_by_token(params[:token])
    raise ActiveRecord::RecordNotFound unless @password_reset.user.account == current_account
    
    @user = @password_reset.user
    return unless request.post?
    
    if !params[:user][:password].blank? && 
      if @user.update_attributes(:password => params[:user][:password],
        :password_confirmation => params[:user][:password_confirmation])
        @password_reset.destroy
        flash[:notice] = "Your password has been updated.  Please log in with your new password."
        redirect_to new_session_url
      end
    end
  end

  protected

  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def create_user_session
    user = authenticate_or_use_token
    if user
      user.reset_admin_login_token
      session[:logged_in_with_admin_token] = logged_in_with_admin_token? || nil

      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      raise ActiveRecord::RecordNotFound
    end
  end


  def create_admin_session
    if params[:login].eql?('') && params[:password].eql?('')
      session[:admin_is_logged_in] = true
      redirect_to root_url
    else
     raise ActiveRecord::RecordNotFound
    end
  end

  private
  
  # Authenticate or use admin login token
  def authenticate_or_use_token
    if params[:token].blank?
      return current_account.users.authenticate(params[:login], params[:password])
    else
      return current_account.users.first(:conditions => { :admin_login_token => params[:token] })
    end
  end  

  # Returns true if the user logged in with admin token
  def logged_in_with_admin_token?
    !params[:token].blank? && self.action_name.to_sym == :create_as_admin
  end
  
  # Returns true if the user is logging out as an admin
  def logging_out_as_admin?
    session[:logged_in_with_admin_token]
  end

  def login_required_if_not_admin
    login_required if session[:admin_is_logged_in].nil?
  end
end
