class AddIsRefundedToSharePrizes < ActiveRecord::Migration
  def change
    add_column :share_prizes, :is_refunded, :integer,:default => 0
  end
end
