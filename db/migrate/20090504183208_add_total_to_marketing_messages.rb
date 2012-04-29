class AddTotalToMarketingMessages < ActiveRecord::Migration
  def self.up
    add_column :marketing_messages, :total, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :marketing_messages, :total
  end
end
