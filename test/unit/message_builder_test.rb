require 'test_helper'

class MessageBuilderTest < ActiveSupport::TestCase

  context "venue name" do
    setup do
      @loc = stub(:name => "location")
      @acc = stub(:venue_name => "account")
    end
    
    should "return location name" do
      assert_equal @loc.name, MessageBuilder.send(:venue_name, @acc, @loc)
    end
    
    should "return account venue name" do
      assert_equal @acc.venue_name, MessageBuilder.send(:venue_name, @acc, nil)
    end
    
    should "return cropped version" do
      assert_equal "0" * MessageBuilder::MAX_VENUE_NAME_SIZE, MessageBuilder.send(:venue_name, nil, stub(:name => "0" * 100)) 
    end
  end

  should "build confirmation message" do
    assert_equal MessageBuilder::CONF_SUFFIX, MessageBuilder.confirmation(
      stub(:conf_prepend_venue => false, :current_offer => nil, :conf_message => nil))

    assert_equal "V:\n#{MessageBuilder::CONF_SUFFIX}", MessageBuilder.confirmation(
      stub(:venue_name => "V", :conf_prepend_venue => true, :current_offer => nil, :conf_message => nil))

    assert_equal "V: m\n#{MessageBuilder::CONF_SUFFIX}", MessageBuilder.confirmation(
      stub(:venue_name => "V", :conf_prepend_venue => true, :current_offer => nil, :conf_message => "m"))
    
    assert_equal "V: m\noffer\n#{MessageBuilder::CONF_WITH_OFFER}#{MessageBuilder::CONF_SUFFIX}", MessageBuilder.confirmation(
      stub(:venue_name => "V", :conf_prepend_venue => true, :current_offer => stub(:text => "offer"), :conf_message => "m"))

    assert_equal "V:\noffer\n#{MessageBuilder::CONF_WITH_OFFER}#{MessageBuilder::CONF_SUFFIX}", MessageBuilder.confirmation(
      stub(:venue_name => "V", :conf_prepend_venue => true, :current_offer => stub(:text => "offer"), :conf_message => ""))
    
    assert_equal "offer\n#{MessageBuilder::CONF_WITH_OFFER}#{MessageBuilder::CONF_SUFFIX}", MessageBuilder.confirmation(
      stub(:venue_name => "V", :conf_prepend_venue => false, :current_offer => stub(:text => "offer"), :conf_message => ""))
    
    assert_equal "m\noffer\n#{MessageBuilder::CONF_WITH_OFFER}#{MessageBuilder::CONF_SUFFIX}", MessageBuilder.confirmation(
      stub(:venue_name => "V", :conf_prepend_venue => false, :current_offer => stub(:text => "offer"), :conf_message => "m"))
    
    assert_equal "Restaurant: Confirmed! We'll notify you when your table is ready.\nTry a martini!\nTxt M for more, HELP for help\nMsg&data rates may apply\nBy recessapp.com", MessageBuilder.confirmation(
      stub(:venue_name => "", :conf_prepend_venue => false, :current_offer => stub(:text => "Try a martini!"), :conf_message => "Restaurant: Confirmed! We'll notify you when your table is ready."))
  end
  
  should "build confirmation email" do
    assert_equal "", MessageBuilder.confirmation_email(
      stub(:conf_prepend_venue => false, :current_offer => nil, :conf_message => nil))

    assert_equal "m", MessageBuilder.confirmation_email(
      stub(:conf_prepend_venue => false, :current_offer => nil, :conf_message => "m"))

    assert_equal "V: m", MessageBuilder.confirmation_email(
      stub(:venue_name => "V", :conf_prepend_venue => true, :current_offer => nil, :conf_message => "m"))

    assert_equal "V: m\nd", MessageBuilder.confirmation_email(
      stub(:venue_name => "V", :conf_prepend_venue => true, :current_offer => stub(:details => "d"), :conf_message => "m"))
  end
  
  should "build page message" do
    assert_equal MessageBuilder::PAGE_SUFFIX, MessageBuilder.page(
      stub(:page_prepend_venue => false, :page_message => nil, :page_append_sub? => false, :current_offer => nil))
    assert_equal "#{MessageBuilder::SUB_WORDING}\n#{MessageBuilder::PAGE_SUFFIX}", MessageBuilder.page(
      stub(:page_prepend_venue => false, :page_message => nil, :page_append_sub? => true, :current_offer => nil))
    assert_equal "#{MessageBuilder::SUB_WORDING}\n#{MessageBuilder::PAGE_WITH_OFFER}#{MessageBuilder::PAGE_SUFFIX}", MessageBuilder.page(
      stub(:page_prepend_venue => false, :page_message => nil, :page_append_sub? => true, :current_offer => true))
    assert_equal "#{MessageBuilder::PAGE_WITH_OFFER}#{MessageBuilder::PAGE_SUFFIX}", MessageBuilder.page(
      stub(:page_prepend_venue => false, :page_message => nil, :page_append_sub? => false, :current_offer => true))

    assert_equal "V:\n#{MessageBuilder::PAGE_SUFFIX}", MessageBuilder.page(
      stub(:venue_name => "V", :page_prepend_venue => true, :page_message => nil, :page_append_sub? => false, :current_offer => nil))

    assert_equal "V: m\n#{MessageBuilder::PAGE_SUFFIX}", MessageBuilder.page(
      stub(:venue_name => "V", :page_prepend_venue => true, :page_message => "m", :page_append_sub? => false, :current_offer => nil))

    assert_equal "m\n#{MessageBuilder::PAGE_SUFFIX}", MessageBuilder.page(
      stub(:venue_name => "V", :page_prepend_venue => false, :page_message => "m", :page_append_sub? => false, :current_offer => nil))
  end
  
  should "build page email" do
    assert_equal "", MessageBuilder.page_email(
      stub(:page_prepend_venue => false, :page_message => nil))

    assert_equal "m", MessageBuilder.page_email(
      stub(:page_prepend_venue => false, :page_message => "m"))

    assert_equal "V: m", MessageBuilder.page_email(
      stub(:venue_name => "V", :page_prepend_venue => true, :page_message => "m"))
  end
  
  should "build free confirmation" do
    assert_equal "This message is to confirm addition to the waitlist.\n" +
      "Msg&data rates may apply\n" +
      "By recessapp.com", MessageBuilder.free_confirmation
  end

  should "build free page" do
    assert_equal "This is the page. You should change these in your account :)\n" +
      "Waitlist offers by recessapp.com", MessageBuilder.free_page
  end
  
  should "build help message" do
    assert /^Waitlist/ =~ MessageBuilder.help(nil)
    assert /^V waitlist/ =~ MessageBuilder.help(stub(:venue_name => "V"))
  end
  
  should "build subscription confirmation" do
    assert /^Subscribed to V special offers/ =~ MessageBuilder.subscription_confirmation(stub(:venue_name => "V"))
  end
  
  should "build stop confirmation" do
    assert /^Opted out of a, b, c/ =~ MessageBuilder.stop_confirmation([ 'a', 'b', 'c' ].join(', '))
    assert /^Opted out of V/ =~ MessageBuilder.stop_confirmation('V')
  end
  
  should "build opt-out menu" do
    assert_equal "To opt out, reply:\n0 for ABC\n1 for DEF\nOr STOP ALL for all", MessageBuilder.optout_menu([ "ABC", "DEF" ])
    assert_equal "To opt out, reply:\n0 for ABC\nOr STOP ALL for all", MessageBuilder.optout_menu([ "ABC" ])
  end

  context "gsm_trim" do
    should "trim GSM string correctly" do
      s = "a|b"
      assert_equal "a",   MessageBuilder.gsm_trim(s, 1)
      assert_equal "a",   MessageBuilder.gsm_trim(s, 2)
      assert_equal "a|",  MessageBuilder.gsm_trim(s, 3)
      assert_equal "a|b", MessageBuilder.gsm_trim(s, 4)
    end
  end
end
