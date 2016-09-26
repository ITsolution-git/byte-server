class AddIsRedeemToSharePrizes < ActiveRecord::Migration
  def change
    add_column :share_prizes, :is_redeem, :integer,:default => 0
  end
end
