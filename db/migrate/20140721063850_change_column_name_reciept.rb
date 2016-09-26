class ChangeColumnNameReciept < ActiveRecord::Migration
  def up
    rename_column :receipts, :notification_id, :notifications_id
  end

  def down
  end
end
