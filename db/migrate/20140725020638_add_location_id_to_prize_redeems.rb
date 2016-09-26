class AddLocationIdToPrizeRedeems < ActiveRecord::Migration
  def change
    add_column :prize_redeems, :location_id, :integer
  end
end
