class AddPointPrizeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :point_prize, :string
  end
end
