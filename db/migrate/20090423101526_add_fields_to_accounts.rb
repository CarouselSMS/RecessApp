class AddFieldsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :venue_name,        :string
    add_column :accounts, :venue_address,     :string
    add_column :accounts, :venue_type,        :string
    add_column :accounts, :venue_type_other,  :string
  end

  def self.down
    remove_column :accounts, :venue_type_other
    remove_column :accounts, :venue_type
    remove_column :accounts, :venue_address
    remove_column :accounts, :venue_name
  end
end
