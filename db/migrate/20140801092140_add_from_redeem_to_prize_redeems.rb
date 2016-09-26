class AddFromRedeemToPrizeRedeems < ActiveRecord::Migration
  def change
    add_column :prize_redeems, :from_redeem, :string
  end
end
