class AddPageAppendSubToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :page_append_sub, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :page_append_sub
  end
end
