require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  should_belong_to :account
  should_have_many :session_messages, :dependent => :nullify
  should_have_many :session_emails,   :dependent => :nullify
  should_validate_presence_of :account_id, :name

end
