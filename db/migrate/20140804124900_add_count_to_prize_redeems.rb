class AddCountToPrizeRedeems < ActiveRecord::Migration
  def change
    add_column :prize_redeems, :count_prize, :integer ,:default => 0
  end
end
