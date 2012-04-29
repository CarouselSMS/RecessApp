require 'test_helper'

class AffiliateTest < ActiveSupport::TestCase

  should_have_many :references, :dependent => :delete_all
  should_have_many :accounts, :through => :references

  should_validate_presence_of :first_name, :last_name, :slug, :email, :percent, :references_count, :accounts_count, :payout, :revenue
  should_validate_uniqueness_of :slug
  should_validate_numericality_of :accounts_count
  should_validate_numericality_of :payout
  should_validate_numericality_of :revenue
  should_validate_numericality_of :percent

  context 'validations' do
    should 'validate percents' do
      assert_invalid_field_values(:percent, -1, 101)
    end

    should "validate accounts_count" do
      assert_invalid_field_values(:accounts_count, -1)
    end
  end


  context 'Affiliate' do
    setup do
      @aff1 = affiliates(:valid_affiliate1)
      @aff2 = affiliates(:valid_affiliate2)

      @sub1 = subscriptions(:place1_1)
      @sub2 = subscriptions(:place2)

      @acc1 = @sub1.account
      @acc2 = @sub2.account

      # create 3 references to affiliate 1
      # and 1 reference to affiliate 2
      @ref_with_aff1_1 = Reference.create!(:affiliate_id => @aff1.id)
      @ref_with_aff1_2 = Reference.create!(:affiliate_id => @aff1.id)
      @ref_with_aff1_3 = Reference.create!(:affiliate_id => @aff1.id)
      @ref_with_aff2_1 = Reference.create!(:affiliate_id => @aff2.id)
    end

    should 'register referenced account' do
      # register 2 accounts with reference to affiliate 1
      Affiliate.register_referenced_account(@acc1, @ref_with_aff1_1.cookie_token)
      Affiliate.register_referenced_account(@acc2, @ref_with_aff1_2.cookie_token)

      @aff1.reload
      @ref_with_aff1_1.reload
      @ref_with_aff1_2.reload
      assert_equal 3, @aff1.references_count # affiliate 1 should have 3 references
      assert_equal 2, @aff1.accounts_count # and only 2 accounts

      payout = (@sub1.amount + @sub2.amount) * (@aff1.percent / 100)
      revenue = [@sub1, @sub2].sum(&:amount)

      assert_equal payout, @aff1.payout
      assert_equal revenue, @aff1.revenue
      assert_equal @acc1.created_at, @ref_with_aff1_1.registered_at
      assert_equal @acc2.created_at, @ref_with_aff1_2.registered_at
    end

    should 'not register account by wrong cookie' do
      Affiliate.register_referenced_account(@acc1, 'sadfasdfasdfasdfasdasdf')
      @acc1.reload
      assert_nil @acc1.affiliate
    end

    should 'not register account twice' do
      Affiliate.register_referenced_account(@acc1, @ref_with_aff1_1.cookie_token)
      Affiliate.register_referenced_account(@acc1, @ref_with_aff1_1.cookie_token)
      @aff1.reload
      @acc1.reload
      assert_equal 1, @aff1.accounts_count

      Affiliate.register_referenced_account(@acc1, @ref_with_aff1_2.cookie_token)
      @aff1.reload
      @acc1.reload
      assert_equal 1, @aff1.accounts_count
    end

  end

  private

  def assert_invalid_field_values(field, *values)
    values.each do |value|
      a = Affiliate.new(field => value)
      a.valid?
      assert_not_nil a.errors[field]
    end
  end

end
