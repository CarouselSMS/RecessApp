class CreateSessionMessages < ActiveRecord::Migration
  def self.up
    create_table :session_messages do |t|
      t.references  :account, :null => false
      t.references  :phone,   :null => false
      t.integer     :kind,    :null => false

      t.timestamps
    end
    
    add_index :session_messages, :account_id
  end

  def self.down
    drop_table :session_messages
  end
end
