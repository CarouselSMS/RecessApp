require 'test_helper'
require File.join(File.dirname(__FILE__), "..", "lib", "sms_toolkit")

class SmsToolkitTest < ActiveSupport::TestCase

  context "phone numbers" do
    context "normalize" do
      should "remove leading 00 from the number" do
        assert_equal "359898658872", normalize("00359898658872")
      end
      should "remove leading 001 from the number" do
        assert_equal "6148048405", normalize("0016148048405")
      end
      should "remove leading +1 from +16148048405" do
        assert_equal "6148048405", normalize("+16148048405")
      end
      should "remove leading 1 from 11-digit US number" do
        assert_equal "6148048405", normalize("16148048405")
      end
      should "leave the number as is if it's normalized" do
        assert_equal "6148048405", normalize("6148048405")
      end
      should "convert (012) 345-6789 to 0123456789" do
        assert_equal "0123456789", normalize(" (012) 345-6789 ")
      end
    end

    context "us formatting" do
      should "convert 0123456789 to (012) 345-6789" do
        assert_equal "(012) 345-6789", format("0123456789")
      end
      should "normalize and convert" do
        assert_equal "(012) 345-6789", format("+10123456789")
      end
      should "leave shortcode as-is" do
        assert_equal "123456", format("123456")
      end
      should "pass on blanks" do
        assert_equal " ", format(" ")
      end
      should "pass on non-numbers" do
        assert_equal "abc", format("abc")
      end
      should "re-format invalid numbers" do
        assert_equal "(012) 345-6789", format("(0123) 45-67-89")
      end
    end
  end
  
  # Calls normalization
  def normalize(number)
    SmsToolkit::PhoneNumbers.normalize(number)
  end

  # Calls US formatting
  def format(number)
    SmsToolkit::PhoneNumbers.format(number)
  end
end
