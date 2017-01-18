class AddPrizeRelationalColumnsToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :prize_type, :integer, default: 0
    add_column :rewards, :points_to_unlock, :integer
    add_column :rewards, :redeem_confirm_msg, :text
  end
end
