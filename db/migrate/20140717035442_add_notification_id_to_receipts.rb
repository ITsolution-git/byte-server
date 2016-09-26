class AddNotificationIdToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :notification_id, :integer
  end
end
