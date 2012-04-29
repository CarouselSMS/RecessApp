class ChangeFieldsOfAdminMessages < ActiveRecord::Migration
  def self.up
    remove_column :admin_messages, :phone_id
  end

  def self.down
    add_column :admin_messages, :phone_id, :integer, :null => false
  end
end
