class ServiceLayer
  
  API_URL = "http://sl.holmesmobile.com/api"
  
  # Sends a message to the given phone number
  def send_message(phone_number, body, action_expected = true)
    api_call("send_message", :phone_number => phone_number, :body => body, :action_expected => action_expected)
  end
  
  # Sends message to all given numbers
  def send_messages(phone_numbers, body)
    phone_numbers.each do |phone_number|
      begin
        send_message(phone_number, body, true)
      rescue => e
        ActiveRecord::Base.logger.error "Failed to deliver manual subscription message to: #{phone_number}"
      end
    end
  end
  
  private
  
  # Makes an API call and returns the results
  def api_call(type, data = {})
    return if RAILS_ENV == "test"
    res = Net::HTTP.post_form(URI.parse(API_URL + "/" + type), data.merge("api_key" => AppConfig['api_key']))
    begin
      return YAML::load(res.body)
    rescue => e
      return res.body
    end
  end
  
end