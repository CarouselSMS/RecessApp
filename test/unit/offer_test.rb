require 'test_helper'

class OfferTest < ActiveSupport::TestCase

  should_belong_to :account
  should_validate_presence_of :name, :text, :account_id
  
end
