require 'test_helper'

class PhoneTest < ActiveSupport::TestCase

  should_validate_presence_of :number
  should_have_many :session_messages,   :dependent => :nullify
  should_have_many :subscriptions,      :dependent => :destroy

end
