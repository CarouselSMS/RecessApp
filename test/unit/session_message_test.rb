require 'test_helper'

class SessionMessageTest < ActiveSupport::TestCase

  should_belong_to :account
  should_belong_to :phone
  should_belong_to :location
  should_validate_presence_of :account_id, :phone_id, :kind

end
