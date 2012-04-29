class CreateSessionEmails < ActiveRecord::Migration
  def self.up
    create_table :session_emails do |t|
      t.references  :account, :null => false
      t.integer     :kind, :null => false
      t.string      :email, :null => false

      t.timestamps
    end
    
    add_index :session_emails, :account_id
  end

  def self.down
    drop_table :session_emails
  end
end
