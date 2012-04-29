require 'test_helper'

class AdminMessageTest < ActiveSupport::TestCase

  should_belong_to :account
  should_validate_presence_of :account_id

end
