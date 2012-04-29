class CreateIphones < ActiveRecord::Migration
  def self.up
    create_table :iphones do |t|
      t.string  :udid,    :null => false
      t.integer :sent,    :null => false, :default => 0
      t.boolean :blocked, :null => false, :default => false

      t.timestamps
    end
    
    add_index :iphones, :udid, :unique => true
  end

  def self.down
    drop_table :iphones
  end
end
