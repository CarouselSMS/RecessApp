class CreateReferences < ActiveRecord::Migration
  def self.up
    create_table :references do |t|
      t.references :affiliate
      t.references :account
      t.string :cookie_token

      t.float     :payment_percent,     :null => false, :default => 0
      t.decimal   :payment_amount,      :null => false, :precision => 8, :scale => 2, :default => 0
      t.decimal   :subscription_amount, :null => false, :precision => 8, :scale => 2, :default => 0

      t.datetime :created_at
      t.datetime :registered_at
    end

    add_index :references, :cookie_token, :unique => true
  end

  def self.down
    drop_table :references
  end
end
