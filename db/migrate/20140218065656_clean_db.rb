class CleanDb < ActiveRecord::Migration
  def change
  	remove_column :users, :badge
  	remove_column :users, :gender
  	remove_column :users, :age
  	drop_table :sessions
  	remove_column :server_avatars, :image_crop
  	remove_column :orders, :order_date
  	remove_column :notifications, :build_menu_id
  	remove_column :notifications, :user_rating
  	remove_column :notifications, :location_logo
  	remove_column :notifications, :about
  	change_column :notifications, :from_user, :integer, limit: nil
  	change_column :user_points, :user_id, :integer, limit: nil
  	change_column :servers, :location_id, :integer, limit: nil
  	remove_column :locations, :redemption_password
  	remove_column :items, :item_grade
  	remove_column :items, :alert_type
  	remove_column :item_nexttimes, :item_id
  	remove_column :friendships, :location_id
  	remove_column :friendships, :point
  	add_column :build_menus, :active, :boolean
  end
end