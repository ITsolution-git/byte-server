class RemoveLocationIdFromSharePrize < ActiveRecord::Migration
  def change
    remove_column :share_prizes, :location_id
    remove_column :share_prizes, :count_prize
    remove_column :prize_redeems, :location_id
    remove_column :prize_redeems, :count_prize
    remove_column :prizes, :location_id
    remove_column :prizes, :token
  end
end
