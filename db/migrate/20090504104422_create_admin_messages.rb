class CreateAdminMessages < ActiveRecord::Migration
  def self.up
    create_table :admin_messages do |t|
      t.references  :account, :null => false
      t.references  :phone,   :null => false

      t.timestamps
    end

    add_index :admin_messages, :account_id
  end

  def self.down
    drop_table :admin_messages
  end
end
