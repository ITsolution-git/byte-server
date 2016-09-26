class ChangeDefaultInNotification < ActiveRecord::Migration
  def up
    change_column :notifications, :status, :integer,:default=>0
    change_column :notifications, :reply, :integer,:default=>0
    change_column :notifications, :received, :integer,:default=>0
  end

  def down
  end
end
