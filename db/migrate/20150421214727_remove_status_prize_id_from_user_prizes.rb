class RemoveStatusPrizeIdFromUserPrizes < ActiveRecord::Migration
  # 'status_prize_id' is a redundant field in the user_prizes table
  # because we have prize_id and status_prize_id is also a Prize attribute.
  # (More to the point, it's normalized that way.)

  def up
    remove_column :user_prizes, :status_prize_id
  end

  def down
    add_column :user_prizes, :status_prize_id, :integer, index: true
  end
end
