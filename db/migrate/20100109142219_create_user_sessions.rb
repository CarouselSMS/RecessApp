class CreateUserSessions < ActiveRecord::Migration
  def self.up
    create_table :user_sessions do |t|
      t.string :session_id
      t.timestamps
    end
    
    create_table :demo_guests do |t|
      t.integer :user_session_id
      t.string  :phone
      t.string  :note
      t.integer :wait_hours
      t.integer :wait_minutes
      t.string  :aasm_state
      t.datetime :deleted_at
      t.integer :party_size
      t.integer :page_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :user_sessions
    drop_table :demo_guests
  end
end

