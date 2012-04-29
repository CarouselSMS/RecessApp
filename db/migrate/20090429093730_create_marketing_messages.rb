class CreateMarketingMessages < ActiveRecord::Migration
  def self.up
    create_table :marketing_messages do |t|
      t.references  :account, :null => false
      t.references  :phone, :null => false
      t.integer     :kind, :null => false
      t.string      :body

      t.timestamps
    end
    
    add_index :marketing_messages, :account_id
  end

  def self.down
    drop_table :marketing_messages
  end
end
