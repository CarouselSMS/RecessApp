require 'test_helper'

class SessionEmailTest < ActiveSupport::TestCase

  should_belong_to :account
  should_belong_to :location
  should_validate_presence_of :account_id, :kind, :email

end
