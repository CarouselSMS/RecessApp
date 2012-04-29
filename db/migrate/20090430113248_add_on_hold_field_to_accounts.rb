class AddOnHoldFieldToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :on_hold, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :on_hold
  end
end
