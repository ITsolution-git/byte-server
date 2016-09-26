class AddLevelToPrizeRedeems < ActiveRecord::Migration
  def change
    add_column :prize_redeems, :level, :integer
    add_column :prize_redeems, :redeem_value, :integer
  end
end
