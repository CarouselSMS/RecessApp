require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  should_have_many :offers,             :dependent => :delete_all
  should_have_many :session_messages,   :dependent => :delete_all
  should_have_many :marketing_messages, :dependent => :delete_all
  should_have_many :admin_messages,     :dependent => :delete_all
  should_have_many :locations,          :dependent => :destroy
  should_have_many :subscribers,        :dependent => :destroy
  should_have_one  :reference,          :dependent => :nullify
  should_have_one  :affiliate,          :dependent => :nullify
  
  context "validation" do
    should "accept domain names with hyphens" do
      a = Account.new(:domain => "a-b-c")
      a.valid?
      assert_nil a.errors['domain']
    end
  end
  
  context "offers" do
    should "set current offer" do
      a = accounts(:place1)
      o = offers(:place1_1)
      a.current_offer = o
      a.save
      
      a.reload
      assert_equal o, a.current_offer
    end
  end

  context "ssl" do
    should "disallow SSL if no subscription" do
      @account = accounts(:place2)
      @account.subscription = nil
      
      assert !@account.ssl_allowed?
    end
    
    should "allow SSL if subscription allows" do
      @account = accounts(:place1)
      sub = @account.subscription

      sub.ssl_allowed = true
      assert @account.ssl_allowed?
      
      sub.ssl_allowed = false
      assert !@account.ssl_allowed?
    end
  end
  
  context "overuse" do
    setup do
      @acc = Account.new
      @acc.stubs(:subscription).returns(stub(:prepaid_message_count => 6))
    end
    
    should "return overuse" do
      @acc.stubs(:usage).returns(10)
      assert_equal 4, @acc.overuse
    end
    
    should "return 0 when no overuse" do
      @acc.stubs(:usage).returns(1)
      assert_equal 0, @acc.overuse
    end
  end
  
  should "reset usage" do
    acc = accounts(:place1)
    assert_equal 0, acc.admin_message_count
    acc.increment!(:admin_message_count)
    
    # Now we update the record as if from another thread
    Account.update_all("admin_message_count = admin_message_count + 4")
    
    acc.reset_usage
    acc.reload
    assert_equal 4, acc.admin_message_count
  end
  
  context "requiring billing info" do
    should "not require for locally registered accounts" do
      acc = Account.new(:locally_registered => true, :plan => subscription_plans(:basic))
      assert acc.needs_payment_info?
    end
    should "require billing info for remotely registered" do
      acc = Account.new(:locally_registered => false, :plan => subscription_plans(:basic))
      assert acc.needs_payment_info?
    end
  end
  
  context "account completeness check" do
    should "report incompleteness" do
      acc = Account.new
      assert acc.incomplete?
    end
    should "report completeness" do
      acc = Account.new(:venue_name => 'Venue', :venue_address => 'Address')
      assert !acc.incomplete?
    end
  end
  
  context "default messages and options on creation" do
    setup do
      @acc = Account.create
    end
    
    should "set confirmation message options" do
      assert_equal "This message is to confirm addition to the waitlist.", @acc.conf_message
      assert @acc.conf_prepend_venue
    end
    
    should "set page options" do
      assert_equal "This is the page. You should change these in your account :)", @acc.page_message
      assert @acc.page_prepend_venue
      assert @acc.page_append_sub
    end
  end
  
  # Asserts the message
  def assert_message(main_part, body, prepend_venue, add_offer = false)
    msg = @account.send(:build_message, body, prepend_venue, add_offer)
    main_part += "\n" unless main_part.blank?
    assert_equal "#{main_part}#{Account::STANDARD_FOOTER}", msg
  end
end
