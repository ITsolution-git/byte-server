class AddIsRedeemToPrizeRedeems < ActiveRecord::Migration
  def change
    add_column :prize_redeems, :is_redeem, :integer
  end
end
