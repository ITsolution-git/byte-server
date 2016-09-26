class AddIsLimitedToSharePrizes < ActiveRecord::Migration
  def change
    add_column :share_prizes, :is_limited, :integer,:default => 0
  end
end
