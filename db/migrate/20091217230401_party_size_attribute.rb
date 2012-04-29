class PartySizeAttribute < ActiveRecord::Migration
  def self.up
    add_column :guests, :party_size, :integer
  end

  def self.down
    remove_column :guests, :party_size
  end
end
