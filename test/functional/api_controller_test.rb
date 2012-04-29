require 'test_helper'

class ApiControllerTest < ActionController::TestCase

  context "info" do
    should "return account info" do
      assert_info('account', {
        "domain"            => "place1.host",
        "venue_name"        => "place1 name", 
        "venue_address"     => "place1 address", 
        "venue_type"        => "other", 
        "venue_type_other"  => "restaurant",
        "on_hold"           => false })
    end
    
    should "return offers" do
      os = accounts(:place1).offers
      assert_info('offers', os.map { |o|
        { "id"              => o.id,
          "name"            => o.name,
          "text"            => o.text,
          "details"         => o.details }
      })
    end

    should "return messages" do
      a = accounts(:place1)
      assert_info('messages', {
        "conf_message"        => a.conf_message,
        "conf_prepend_venue"  => a.conf_prepend_venue,
        "page_message"        => a.page_message,
        "page_prepend_venue"  => a.page_prepend_venue,
        "offer_id"            => a.offer_id
      })
    end

    should "return usage stats" do
      a = accounts(:place1)
      a.update_attribute(:session_message_count, 10)
      a.update_attribute(:marketing_message_count, 11)
      assert_info('usage', {
        "session_messages"    => 10,
        "marketing_messages"  => 11,
        "prepaid_messages"    => 250
      })
    end
    
    should "return locations" do
      a = accounts(:place1)
      ls = a.locations
      assert_info('locations', ls.map { |l|
        { "id"          => l.id,
          "name"        => l.name,
          "internal_id" => l.internal_id }
      })
    end
  end

  context "update_messages" do
    setup { login_as :place1_admin }
    context "update messages" do
      setup do
        @a = accounts(:place1)
        get :update_messages, :messages => {
          :conf_message => "cm", :conf_prepend_value => "1",
          :page_message => "pm", :page_prepend_value => "1",
          :offer_id => @a.offers.first.id }
      end
      should_respond_with :success
      should "return empty body" do
        assert @response.body.empty?
      end
    end
  end
  
  [ :confirmation, :page ].each do |msg_type|
    context "send free #{msg_type.to_s}" do
      context "success (known phone)" do
        setup do
          @iphone = iphones(:second_use)
          get "send_free_#{msg_type.to_s}", :phone_number => "0123456789", :udid => @iphone.udid
        end
        should_respond_with :success
        should "update :sent" do
          assert_equal 2, @iphone.reload.sent
        end
      end
    
      context "success (new phone)" do
        setup do
          get "send_free_#{msg_type.to_s}", :phone_number => "0123456789", :udid => "a" * 40
        end
        should_respond_with :success
        should "update :sent" do
          iphone = Iphone.find_by_udid("a" * 40)
          assert_equal 1, iphone.reload.sent
        end
      end
    
      [ :blocked, :empty ].each do |iphone_key|
        context "failure (phone is #{iphone_key.to_s})" do
          setup do
            @iphone = iphones(iphone_key)
            get "send_free_#{msg_type.to_s}", :phone_number => "0123456789", :udid => @iphone.udid
          end
          should_respond_with 500
          should "fill message body" do
            assert /not allowed/ =~ @response.body
          end
        end
      end
    end
  end

  context "send confirmation" do
    setup { login_as :place1_admin }

    context "no phone" do
      setup { get :send_confirmation }
      should_respond_with :error
      should "return error" do
        assert /neither .* were given/i =~ @response.body
      end
    end

    context "on hold" do
      setup do
        @acc = accounts(:place1)
        @acc.update_attribute(:on_hold, true)
        @controller.stubs(:current_account).returns(@acc)
        get :send_confirmation, :phone_number => "0123401234"
      end
      should_respond_with :error
      should "return error" do
        assert /on hold/i =~ @response.body
      end
    end
        
    context "success (phone)" do
      setup do
        SessionMessage.delete_all
        @account = accounts(:place1)
        get :send_confirmation, :phone_number => "0123401234"
        @msg = SessionMessage.last
      end
      should_respond_with :success
      should "return message id" do
        resp = JSON.parse(@response.body)
        assert_equal @msg.id, resp["message_id"]
        assert_equal 0,       resp["usage"]["session_messages"]
        assert_equal 0,       resp["usage"]["marketing_messages"]
        assert_equal 250,     resp["usage"]["prepaid_messages"]
      end
      should "register message" do
        @account.reload
        assert_equal 0, @account.session_message_count.to_i
      end
    end
    
    context "success (email)" do
      setup do
        @account = accounts(:place1)
        get :send_confirmation, :email => "test@email.com"
      end
      should_respond_with :success
      should "send email" do
        sent = ActionMailer::Base.deliveries.last
        assert_equal  [ "test@email.com" ], sent.to
        assert_equal  "Confirmation", sent.subject
        assert        /#{@account.conf_message}/ =~ sent.body
      end
    end
  end

  context "send page" do
    setup { login_as :place1_admin }

    context "no phone" do
      setup { get :send_page }
      should_respond_with :error
      should "return error" do
        assert /neither .* were given/i =~ @response.body
      end
    end

    context "on hold" do
      setup do
        @acc = accounts(:place1)
        @acc.update_attribute(:on_hold, true)
        @controller.stubs(:current_account).returns(@acc)
        get :send_page, :phone_number => "0123401234"
      end
      should_respond_with :error
      should "return error" do
        assert /on hold/i =~ @response.body
      end
    end

    context "success" do
      setup do
        SessionMessage.delete_all
        @account = accounts(:place1)
        get :send_page, :phone_number => "0123401234"
        @msg = SessionMessage.last
      end
      should_respond_with :success
      should "return message id" do
        resp = JSON.parse(@response.body)
        assert_equal @msg.id, resp["message_id"]
        assert_equal 1,       resp["usage"]["session_messages"]
        assert_equal 0,       resp["usage"]["marketing_messages"]
        assert_equal 250,     resp["usage"]["prepaid_messages"]
      end
      should "register message" do
        @account.reload
        assert_equal 1, @account.session_message_count
      end
    end
    
    context "success (email)" do
      setup do
        @account = accounts(:place1)
        get :send_page, :email => "test@email.com"
      end
      should_respond_with :success
      should "send email" do
        sent = ActionMailer::Base.deliveries.last
        assert_equal  [ "test@email.com" ], sent.to
        assert_equal  "Notification", sent.subject
        assert        /#{@account.page_message}/ =~ sent.body
      end
    end
  end

  context "iphone_required filter" do
    should "catch empty UDID" do
      assert_raises RuntimeError do
        @controller.send(:iphone_required, " ")
      end
    end

    should "catch invalid UDID" do
      assert_raises RuntimeError do
        @controller.send(:iphone_required, "a" * 30)
      end
    end

    should "catch overused UDID" do
      assert_raises RuntimeError do
        @controller.send(:iphone_required, iphones(:empty).udid)
      end
    end
    
    should "pass valid one" do
      @controller.send(:iphone_required, iphones(:second_use).udid)
    end
  end
  
  context "normalize phone and check" do
    should "catch invalid numbers" do
      [ "a", "1", "09876543210", "9123", "99999 88888" ].each do |number|
        assert_raises RuntimeError do
          @controller.send(:normalize_phone, number)
        end
      end
    end
    
    should "accept valid" do
      [ "19999988888", "9999988888" ].each do |number|
        @controller.send(:normalize_phone, number)
      end
    end
  end
  
  context "choose location" do
    should "return location_id if location_id is given" do
      assert_equal 1, choose_location(1, 2)
    end
    
    should "return current_user.location_id if location_id isn't given" do
      assert_equal 2, choose_location(nil, 2)
    end
    
    should "return nothing if no location known" do
      assert_nil choose_location(nil, nil)
    end
  end
  
  context "delivery report" do
    setup do
      login_as :place1_admin
      @pending = session_messages(:place1_pending)
      @sent    = session_messages(:place1_delivered)
    end
    
    context "single message" do
      setup { get :delivery_report, :message_ids => @pending.id.to_s }
      should_respond_with :success
      should "return the status" do
        resp = { @pending.id => { :status => @pending.dlr_status, :final => @pending.dlr_final } }.to_json
        assert_equal resp, @response.body
      end
    end
    
    context "several messages" do
      setup { get :delivery_report, :message_ids => [ @pending, @sent ].map(&:id).join(",") }
      should_respond_with :success
      should "return the status" do
        resp = { @pending.id => { :status => @pending.dlr_status, :final => @pending.dlr_final },
                 @sent.id    => { :status => @sent.dlr_status,    :final => @sent.dlr_final } }.to_json
        assert_equal resp, @response.body
      end
    end
    
    context "missing" do
      setup { get :delivery_report, :message_ids => "0" }
      should_respond_with :success
      should "return the status" do
        resp = { }.to_json
        assert_equal resp, @response.body
      end
    end
  end
  
  private

  # Simulator of the call
  def choose_location(params_location_id, current_user_location_id)
    @controller.stubs(:params).returns({ :location_id => params_location_id })
    @controller.stubs(:current_user).returns(stub(:location_id => current_user_location_id))
    @controller.send(:choose_location)
  end
  
  # Calls info API call and returns the hash with results
  def info(kind)
    login_as :place1_admin
    get :info, :kind => kind

    # See if the response is success
    assert_equal "200", @response.code

    return JSON.parse(@response.body)
  end

  def assert_info(kind, target)
    data = info(kind)
    data = data[kind]
    
    if target.kind_of?(Array)
      assert data.kind_of?(Array)
      assert_equal target.size, data.size
      target.each_with_index { |t, i| assert_hash(data[i], t) }
    else
      assert_hash(data, target)
    end
  end
  
  def assert_hash(data, target)
    target.each do |k, v|
      assert_equal v, data.delete(k)
    end
    
    assert data.empty?
  end
end
