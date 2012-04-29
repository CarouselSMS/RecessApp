class CreatePhones < ActiveRecord::Migration
  def self.up
    create_table :phones do |t|
      t.string  :number, :null => false
      t.integer :last_account_id

      t.timestamps
    end

    add_index :phones, :number, :unique => true
  end

  def self.down
    drop_table :phones
  end
end
