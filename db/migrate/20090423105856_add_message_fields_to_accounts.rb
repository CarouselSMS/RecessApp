class AddMessageFieldsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :conf_message,        :string
    add_column :accounts, :conf_prepend_venue,  :boolean, :default => true
    add_column :accounts, :page_message,        :string
    add_column :accounts, :page_prepend_venue,  :boolean, :default => true
    add_column :accounts, :offer_id,            :integer
  end

  def self.down
    remove_column :accounts, :offer_id
    remove_column :accounts, :page_prepend_venue
    remove_column :accounts, :page_message
    remove_column :accounts, :conf_prepend_venue
    remove_column :accounts, :conf_message
  end
end
