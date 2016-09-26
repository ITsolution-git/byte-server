class AddSharePrizeIdToPrizeRedeems < ActiveRecord::Migration
  def change
    add_column :prize_redeems, :share_prize_id, :integer
  end
end
