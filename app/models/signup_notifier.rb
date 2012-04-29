class SignupNotifier < ActionMailer::Base

  def step(step, data)
    data[:user][:password].replace('[FILTERED]')              unless data[:user].nil? || data[:user][:password].nil?
    data[:user][:password_confirmation].replace('[FILTERED]') unless data[:user].nil? || data[:user][:password_confirmation].nil?

    data[:creditcard][:number].replace('[FILTERED]')              unless data[:creditcard].nil? || data[:creditcard][:number].nil?
    data[:creditcard][:verification_value].replace('[FILTERED]')  unless data[:creditcard].nil? || data[:creditcard][:verification_value].nil?

    setup_email("Singup form step #{step.to_i}")
    @body = { :partial_form => data , :step => step.to_i}
  end

  private

  def setup_email(subject, from = AppConfig['from_email'])
    @sent_on = Time.now
    @subject = subject
    @recipients = AppConfig['partial_form_recipient']
    @from = from.respond_to?(:email) ? from.email : from
  end

end
