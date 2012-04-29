class AddLocallyRegisteredToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :locally_registered, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :locally_registered
  end
end
