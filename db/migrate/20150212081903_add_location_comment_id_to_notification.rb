class AddLocationCommentIdToNotification < ActiveRecord::Migration
  def self.up
    Notifications.reset_column_information
    unless Notifications.column_names.include?('location_comment_id')
      add_column :notifications, :location_comment_id, :integer
    end
  end

  def self.down
    Notifications.reset_column_information
    if Notifications.column_names.include?('location_comment_id')
      remove_column(:notifications, :location_comment_id)
    end
  end
end
