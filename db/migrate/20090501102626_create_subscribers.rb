class CreateSubscribers < ActiveRecord::Migration
  def self.up
    create_table :subscribers do |t|
      t.references  :account,         :null => false
      t.references  :phone,           :null => false
      t.datetime    :next_renewal_at, :null => false

      t.timestamps
    end
    
    add_index :subscribers, [:account_id, :phone_id], :unique => true
    add_index :subscribers, :next_renewal_at
  end

  def self.down
    drop_table :subscribers
  end
end
