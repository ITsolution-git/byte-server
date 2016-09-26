class AddApprovedToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :approved, :integer,:default => 0
  end
end
