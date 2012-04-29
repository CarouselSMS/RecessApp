require 'test_helper'

class MO::HandlerTest < ActiveSupport::TestCase
  
  context "responding to M(ORE)" do
    should "when phone is unknown" do
      assert_nil process("0000000001", "m")
    end
    
    should "when no last account link" do
      assert_nil process(:no_app_link, "m")
    end
    
    should "when no active offer" do
      assert_nil process(:no_active_offer, "m")
    end
    
    should "when offer is present" do
      MarketingMessage.delete_all
      
      offer = offers(:place1_1)
      assert_equal offer.details, process(:one, "m")
      
      account = accounts(:place1)
      message = account.marketing_messages.last
      assert_equal MarketingMessage::KIND_OFFER_DETAILS, message.kind
      assert_equal offer.details, message.body
    end
  end

  should "HELP" do
    acc = accounts(:place1)
    
    assert /^place1 name waitlist/ =~ handle("help")
    acc.reload
    assert_equal 1, acc.admin_messages.count

    body, kind = get_response("help")
    assert /^place1 name waitlist/ =~ body
    assert kind == :admin
  end
  
  context "SUB" do
    should "no last account link" do
      assert_nil process(:no_app_link, "sub")
    end
    
    should "already subscribed" do
      @acc = accounts(:place1)
      @pho = phones(:one)
      @sub = @acc.subscribers.create!(:phone => @pho)
      
      # Allow continuous subscription (#147)
      assert /^Subscribed/ =~ process(:one, "sub")
    end
    
    should "subscribe" do
      assert /^Subscribed/ =~ process(:one, "sub")
      phones(:one).reload
      assert phones(:one).subscriptions.map(&:account) == [ accounts(:place1) ]
    end
  end
  
  context "STOP" do
    should "with no subscriptions" do
      assert_nil handle("stop")
    end
    
    should "with one subscription only" do
      acc = accounts(:place1)
      acc.subscribers.create!(:phone => phones(:one))

      assert /^Opted out/ =~ handle("stop")

      acc.reload
      assert_equal 0, acc.subscribers_count
      assert acc.subscribers.empty?
      assert_equal 1, acc.admin_messages.count
    end
    
    should "with multiple subscriptions" do
      pho = phones(:one)
      pho.subscriptions.create!(:account => accounts(:place1))
      pho.subscriptions.create!(:account => accounts(:place2))
      
      assert /^To opt out/ =~ handle("stop")
      
      pho.reload
      assert_equal 2, pho.subscriptions.count
    end
  end
  
  context "STOP ALL" do
    setup do
      AdminMessage.delete_all
      @pho = phones(:one)
      @pho.subscriptions.create!(:account => accounts(:place1))
      @pho.subscriptions.create!(:account => accounts(:place2))
    end

    should "with no subscriptions" do
      @pho.subscriptions.delete_all
      assert_nil handle("STOP ALL")
    end

    should "with multiple subscriptions (STOP ALL)" do
      assert /^Opted out of place1 name, place2 name/ =~ handle("stop all")
      @pho.reload
      assert @pho.subscriptions.empty?
      assert_equal 0, @pho.subscriptions.count
    end

    should "with multiple subscriptions (STOPALL)" do
      assert /^Opted out of place1 name, place2 name/ =~ handle("stopALL")
      @pho.reload
      assert_equal 0, @pho.subscriptions.count
    end
    
    should "record" do
      handle("stop all")
      assert_equal 1, AdminMessage.count
    end
  end
  
  context "choosing in opt-out menu" do
    setup do
      @pho = phones(:one)
      @pho.update_attribute(:optout_before, 10.minutes.from_now)
      @pho.subscriptions.create!(:account => accounts(:place1))
      @pho.subscriptions.create!(:account => accounts(:place2))
    end
    
    should "return false if not number" do
      assert !optout("not a number")

      @pho.reload
      assert !@pho.opting_out?
      assert 2, @pho.subscriptions.count
    end
    
    should "unsubscribe chosen" do
      body, kind = optout("0")
      assert /^Opted out of place1 name/ =~ body
      assert kind == :admin
      
      @pho.reload
      assert !@pho.opting_out?
      assert [ accounts(:place2) ], @pho.subscriptions.map(&:account)
    end
    
    should "ignore if out of range" do
      assert_nil optout("3")

      @pho.reload
      assert !@pho.opting_out?
      assert 2, @pho.subscriptions.count
    end
  end
  
  context "responding to unknown" do
    should "return nil" do
      assert_nil process(phones(:one).number, "unknown message")
    end
  end
  
  should "record admin message" do
    AdminMessage.delete_all
    
    acc = accounts(:place1)
    pho = phones(:one)
    
    MO::Handler.send(:record_response, acc, :admin)
    
    acc.reload
    assert_equal 1, acc.admin_messages.count
  end
  
  private
  
  # Shorcut to process
  def process(phone, body)
    phone = phones(phone).number if phone.is_a?(Symbol)
    MO::Handler.process(phone, body)
  end
  
  # Process with valid phone
  def handle(body)
    process(:one, body)
  end
  
  # Returns the response and kind
  def get_response(body)
    MO::Handler.send(:get_response, phones(:one), body)
  end
  
  # Process opt out
  def optout(body)
    MO::Handler.send(:process_opt_out, phones(:one), body)
  end
end