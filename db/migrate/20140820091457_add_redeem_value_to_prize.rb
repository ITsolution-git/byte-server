class AddRedeemValueToPrize < ActiveRecord::Migration
  def change
    add_column :user_prizes, :status_prize_id, :integer
  end
end
