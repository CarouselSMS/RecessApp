class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.references :account, :null => false
      t.string :name, :null => false
      t.string :text, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :offers
  end
end
