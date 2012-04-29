class CreateAffiliates < ActiveRecord::Migration
  def self.up
    create_table :affiliates do |t|
      t.string  :first_name, :null => false
      t.string  :last_name,  :null => false
      t.string  :email,      :null => false
      t.string  :slug,       :null => false

      t.float   :percent,    :null => false

      t.integer :references_count, :null => false, :default => 0
      t.integer :accounts_count,    :null => false, :default => 0

      t.decimal  :revenue,  :null => false, :precision => 8, :scale => 2, :default => 0 #lifetime revenue
      t.decimal  :payout,   :null => false, :precision => 8, :scale => 2, :default => 0 #lifetime payout

      t.timestamps
    end

    add_index :affiliates, :slug, :unique => true
  end

  def self.down
    drop_table :affiliates
  end
end
