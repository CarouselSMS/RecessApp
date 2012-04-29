class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.references  :account, :null => false
      t.string      :name,    :null => false
      t.string      :internal_id

      t.timestamps
    end
    
    add_index :locations, :account_id
  end

  def self.down
    drop_table :locations
  end
end
