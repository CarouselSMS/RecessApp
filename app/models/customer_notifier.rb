class CustomerNotifier < ActionMailer::Base

  def confirmation(recipient, account, location = nil)
    setup_email(recipient, "Confirmation")
    @body = { :account => account, :location => location }
  end
  
  def page(recipient, account, location = nil)
    setup_email(recipient, "Notification")
    @body = { :account => account, :location => location }
  end
  
  private
  
  def setup_email(to, subject, from = AppConfig['from_email'])
    @sent_on = Time.now
    @subject = subject
    @recipients = to.respond_to?(:email) ? to.email : to
    @from = from.respond_to?(:email) ? from.email : from
  end

end
