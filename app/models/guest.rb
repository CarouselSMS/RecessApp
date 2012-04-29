class Guest < ActiveRecord::Base
  include AASM
  PARTY_SIZE = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  belongs_to :waitlist

  acts_as_paranoid
  acts_as_audited

  validates_presence_of :phone, :waitlist_id

  aasm_initial_state :waiting
  aasm_state :waiting
  aasm_state :paged
  aasm_state :arrived
  aasm_state :noshow

  # Basically allow all transitions

  aasm_event :page do
    transitions :from => :waiting, :to => :paged
    transitions :from => :noshow, :to => :paged
    transitions :from => :paged, :to => :paged
    transitions :from => :arrived, :to => :paged
  end

  aasm_event :arrive do
    transitions :from => :paged, :to => :arrived
    transitions :from => :waiting, :to => :arrived
    transitions :from => :noshow, :to => :arrived
  end

  aasm_event :absent do
    transitions :from => :paged, :to => :noshow
    transitions :from => :waiting, :to => :noshow
    transitions :from => :arrived, :to => :noshow
  end

  aasm_event :send_to_waiting do
    transitions :from => :paged, :to => :waiting
    transitions :from => :arrived, :to => :waiting
    transitions :from => :noshow, :to => :waiting
    transitions :from => :waiting, :to => :waiting
  end

  named_scope :waiting, :conditions => { :aasm_state => 'waiting' }, :order => 'created_at desc'
  named_scope :paged, :conditions => { :aasm_state => 'paged' }, :order => 'created_at desc'
  named_scope :arrived, :conditions => { :aasm_state => 'arrived' }, :order => 'created_at desc'
  named_scope :noshow, :conditions => { :aasm_state => 'noshow' }, :order => 'created_at desc'

  def arrival_time
    return '' if wait_hours.nil? || wait_minutes.nil?
    created_at + (wait_hours * 60 + wait_minutes).minutes
  end

  def note
    read_attribute(:note).blank? ? "Guest ##{ self.id }" : read_attribute(:note)
  end

  def wait
    return '' if wait_hours.blank?
    wait_hours > 0 ? "#{ wait_hours }h #{ wait_minutes }m" : "#{ wait_minutes }m"
  end

  def waiting_time
    in_sec = Time.now - created_at
    "#{ (in_sec/60).to_i }m"
  end

  def remaining_wait_time
    return '' if arrival_time.blank?
    in_sec = arrival_time - Time.now
    in_mins = (in_sec/60).to_i
    if in_mins > 0
      "<span>#{ in_mins }m left</span>"
    else
      "<span class='late'>#{ in_mins * -1 }m late</span>"
    end
  end

  def send_page!(account)
    unless self.phone.blank?
      messaging = Messaging.new(account, account)
      messaging.send_page(normalize_phone(self.phone), self.waitlist.location_id)
      page!
      self.increment!(:page_count)
    else
      false
    end
  end

  def send_confirmation!(account)
    unless self.phone.blank?
      messaging = Messaging.new(account, account)
      messaging.send_confirmation(normalize_phone(self.phone), self.waitlist.location_id)
    else
      false
    end
  end

  private
  def normalize_phone(phone_number)
    raise "Phone number is blank" if phone_number.blank?
    SmsToolkit::PhoneNumbers.normalize(phone_number)
  end
end
