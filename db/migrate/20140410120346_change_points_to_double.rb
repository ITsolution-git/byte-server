class ChangePointsToDouble < ActiveRecord::Migration
  def change
    change_column :users, :points, :float, :limit => 53
    change_column :notifications, :points, :float, :limit => 53
    change_column :user_points, :points, :float, :limit => 53
    change_column :share_points, :points, :float, :limit => 53
    change_column :dinner_types, :point, :float, :limit => 53
    change_column :order_items, :use_point, :float, :limit => 53
  end
end
