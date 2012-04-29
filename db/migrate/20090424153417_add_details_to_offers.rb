class AddDetailsToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :details, :string
  end

  def self.down
    remove_column :offers, :details
  end
end
