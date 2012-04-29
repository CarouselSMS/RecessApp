class AddSessionEmailsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :session_email_count, :integer
  end

  def self.down
    remove_column :accounts, :session_email_count
  end
end
