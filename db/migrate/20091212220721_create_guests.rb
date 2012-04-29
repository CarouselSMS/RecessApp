class CreateGuests < ActiveRecord::Migration
  def self.up
    create_table :guests do |t|
      t.integer :waitlist_id
      t.string :phone
      t.string :note
      t.integer :wait_hours
      t.integer :wait_minutes
      t.string :aasm_state
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :guests, :waitlist_id
  end

  def self.down
    drop_table :guests
  end
end
