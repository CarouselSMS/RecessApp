require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase

  should_validate_presence_of :name
  should_validate_presence_of :email

end
