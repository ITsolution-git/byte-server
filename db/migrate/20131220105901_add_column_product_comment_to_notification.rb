class AddColumnProductCommentToNotification < ActiveRecord::Migration
  def change
  	add_column :notifications, :product_comment, :text
  end
end
