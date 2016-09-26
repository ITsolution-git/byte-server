class AddIsShow < ActiveRecord::Migration
  def up
  	add_column :notifications, :is_show, :integer, :default => 1
  end

  def down
  end
end
