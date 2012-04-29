class SlCallbacksController < ApplicationController

  # Disable CSRF
  skip_before_filter :verify_authenticity_token
  skip_before_filter :login_required
  skip_before_filter :set_selected_tab
  
  # Entry point
  def index
    if params[:type]
      case params[:type]
      when "incoming_message"
        incoming_message
      when "delivery_report"
        delivery_report
      else
        render :text => ""
      end
    else
      render :text => ""
    end
  end
  
  private
  
  # Incoming message processing
  def incoming_message
    phone_number = params[:phone_number]
    body         = params[:body]

    render :text => MO::Handler.process(phone_number, body)
  end
  
  # Delivery report from SL
  def delivery_report
    dlr_message_id = params[:message_id]
    dlr_status     = params[:status]
    dlr_final      = params[:final].to_i

    # Update the delivery status
    SessionMessage.update_all("dlr_status = #{dlr_status}, dlr_final = #{dlr_final}", "dlr_message_id = #{dlr_message_id}")
    
    render :text => ""
  end
end
