class AddAdminLoginTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :admin_login_token, :string
  end

  def self.down
    remove_column :users, :admin_login_token
  end
end
