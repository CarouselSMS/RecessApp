class AddMobileToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :mobile, :string, :null => false
  end

  def self.down
    remove_column :users, :mobile
  end
end
