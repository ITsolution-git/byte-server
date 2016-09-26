class AddColumnItemCommentIdToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :item_comment_id, :integer
  end
end
