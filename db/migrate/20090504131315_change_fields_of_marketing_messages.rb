class ChangeFieldsOfMarketingMessages < ActiveRecord::Migration
  def self.up
    add_column    :marketing_messages, :recipients, :integer, :default => 1, :null => false
    add_column    :marketing_messages, :parts, :integer, :default => 1, :null => false
    remove_column :marketing_messages, :phone_id
  end

  def self.down
    add_column    :marketing_messages, :phone_id, :integer, :null => false
    remove_column :marketing_messages, :parts
    remove_column :marketing_messages, :recipients
  end
end
