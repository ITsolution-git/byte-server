class AddSharePrizeIdToSharePrizes < ActiveRecord::Migration
  def change
    add_column :share_prizes, :share_id, :integer,:default => 0
  end
end
