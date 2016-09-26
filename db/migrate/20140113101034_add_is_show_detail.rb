class AddIsShowDetail < ActiveRecord::Migration
  def up
	add_column :notifications, :is_show_detail, :integer, :default => 1
  end

  def down
  end
end
