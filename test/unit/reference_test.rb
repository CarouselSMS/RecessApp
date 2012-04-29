require 'test_helper'

class ReferenceTest < ActiveSupport::TestCase

  should_belong_to :affiliate, :account

  should_validate_uniqueness_of :cookie_token


  context 'Reference' do
    should 'generate cookie_token on create' do
      aff = Affiliate.first
      ref = Reference.create!(:affiliate_id => aff.id)

      assert_not_nil ref.cookie_token
    end

    should 'increase affiliate counters (references_count) on create' do
      aff = Affiliate.first
      references_count = 3

      references_count.times do
        Reference.create!(:affiliate_id => aff.id)
      end

      aff.reload
      assert_equal references_count, aff.references_count
    end
  end
  
end
