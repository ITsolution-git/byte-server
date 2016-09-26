class AddColumnGroupEmailsToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :group_emails, :text
  end
end
