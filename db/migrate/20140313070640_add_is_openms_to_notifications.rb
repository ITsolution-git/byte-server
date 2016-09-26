class AddIsOpenmsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :is_openms, :integer,:default => 0
  end
end
