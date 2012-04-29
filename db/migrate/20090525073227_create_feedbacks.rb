class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.string  :name, :null => false
      t.string  :email, :null => false
      t.string  :company
      t.string  :position
      t.string  :industry
      t.boolean :using_ps
      t.string  :using_ps_details
      t.boolean :using_ws
      t.string  :using_ws_details
      t.text    :how_working
      t.string  :how_found
      t.text    :additional_info
      t.text    :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
