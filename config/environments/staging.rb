# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

config.after_initialize do
  ActiveMerchant::Billing::Base.gateway_mode = :test
end

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address    => "",
  :port       => 26,
  :user_name  => "",
  :password   => "",
  :domain     => "",
  :enable_starttls_auto => true,
  :authentication => :plain
}


ActionController::Base.class_eval do

  prepend_before_filter :authenticate_for_staging

  def authenticate_for_staging
    success = authenticate_or_request_with_http_digest("Staging") do |username|
      if username == "soon"
        "soon"
      end
    end

    unless success
      request_http_digest_authentication("Staging", "Authentication failed")
    end
  end

end