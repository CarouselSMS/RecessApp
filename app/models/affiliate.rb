class Affiliate < ActiveRecord::Base

  has_many :references, :dependent => :delete_all
  has_many :accounts, :through => :references

  validates_presence_of :first_name, :last_name, :slug, :email, :percent, :references_count, :accounts_count, :payout, :revenue

  validates_uniqueness_of :slug
  
  validates_numericality_of :accounts_count, :greater_than_or_equal_to => 0

  validates_numericality_of :payout,  :greater_than_or_equal_to => 0
  validates_numericality_of :revenue, :greater_than_or_equal_to => 0
  validates_numericality_of :percent, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100, :allow_nil => true

  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  validates_format_of       :slug,     :with => /\A[a-zA-Z0-9\-_]+\Z/


  class << self
    # call this method, when new account created
    # sets the reference payment info, associate reference with the account,
    # updates reference affilate counters: lifetime payout, lifetime revenue, signups
    def register_referenced_account(account, cookie_token)
      account = Account.find(account.to_i) unless account.is_a?(Account)
      return false unless account.affiliate.nil?
      reference = Reference.first( :conditions => { :cookie_token => cookie_token, :account_id => nil } )
      return false if reference.nil?
      affiliate = reference.affiliate

      Reference.transaction do
        reference.account_id          = account.id
        reference.subscription_amount = account.subscription.amount
        reference.payment_percent     = affiliate.percent
        reference.payment_amount      = reference.subscription_amount * ( reference.payment_percent / 100 )
        reference.registered_at       = account.created_at

        affiliate.payout          = affiliate.payout  + reference.payment_amount
        affiliate.revenue         = affiliate.revenue + reference.subscription_amount
        affiliate.accounts_count  = affiliate.accounts_count + 1

        return reference.save! && affiliate.save!
      end
    end
  end




  def name
    "#{first_name} #{last_name}"
  end

  def ratio
    "#{(accounts_count*100/references_count).to_i}%" rescue '-'
  end

  def payout_this_month
    payout_by_period(Time.now.beginning_of_month, Time.now)
  end


  def payout_previous_month
    beginning_of_month = Time.now.beginning_of_month
    payout_by_period(beginning_of_month - 1.month, beginning_of_month - 1.second)
  end


  def payout_by_period(date_start, date_end)
    references.sum(:payment_amount, :conditions => {:registered_at => (date_start..date_end)})
  end

  def monthly_stats
    result = {}

    references_stats = references.all(
      :group => "DATE_FORMAT(created_at, '%Y %m')",
      :select => "created_at as `date`, DATE_FORMAT(created_at, '%Y %m') as `month`, COUNT(*) as references_count" )

    signups_stats = references.all(
      :conditions => 'NOT ISNULL(registered_at)',
      :group  => "DATE_FORMAT(registered_at, '%Y %m')",
      :select => "registered_at as `date`, DATE_FORMAT(registered_at, '%Y %m') as `month`, SUM(payment_amount) as payment_amount, SUM(subscription_amount) as subscription_amount, COUNT(registered_at) as accounts_count" )

    # add references_count field
    signups_stats.each do |row|
      result[ row['month'] ] = row
      result[ row['month'] ]['date'] = Date.parse(row['date'].to_s)
      result[ row['month'] ]['references_count'] = references_stats.select{ |v| v['month'].eql?( row['month'] ) }.first['references_count'] rescue 0
    end

    # months without signups, but with the references
    references_stats.each do |row|
      if result[ row['month'] ].nil?
        result[ row['month'] ] = {
          'date'                => Date.parse(row['date'].to_s),
          'month'               => row['month'],
          'payment_amount'      => 0,
          'subscription_amount' => 0,
          'references_count'    => row['references_count'],
          'accounts_count'      => 0 }
      end
    end

    # sort by month
    return result.sort{ |a,b| a[0] <=> b[0] }
  end
end
