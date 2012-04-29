class GuestPagedCount < ActiveRecord::Migration
  def self.up
    add_column :guests, :page_count, :integer, :default => 0
  end

  def self.down
    remove_column :guests, :page_count
  end
end
