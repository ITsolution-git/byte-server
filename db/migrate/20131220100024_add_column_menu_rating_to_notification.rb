class AddColumnMenuRatingToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :menu_rating, :integer, :default=>0
    add_column :notifications, :user_rating, :integer
  end
end
