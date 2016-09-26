class RemoveApprovedFromNotifications < ActiveRecord::Migration
  # NOTE: This is a destructive migration.  It cannot be reversed -
  # once the unapproved Notifications are gone, they are gone for good.

  # There is no longer an approval process for comments, so we
  # are removing the 'approved' column.
  def up
    execute <<-SQL
      DELETE FROM notifications
      WHERE approved = 0
    SQL

    remove_column :notifications, :approved
  end

  def down
    add_column :notifications, :approved, :boolean
  end
end
