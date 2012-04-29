class CreateWaitlists < ActiveRecord::Migration
  def self.up
    create_table :waitlists do |t|
      t.integer :location_id
      t.timestamps
    end
  end

  def self.down
    drop_table :waitlists
  end
end
