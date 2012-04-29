class AddOptoutBeforeToPhones < ActiveRecord::Migration
  def self.up
    add_column :phones, :optout_before, :datetime
  end

  def self.down
    remove_column :phones, :optout_before
  end
end
