class AddCountToSharePrizes < ActiveRecord::Migration
  def change
    add_column :share_prizes, :count_prize, :integer,:default => 0
  end
end
