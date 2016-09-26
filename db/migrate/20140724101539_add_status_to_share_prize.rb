class AddStatusToSharePrize < ActiveRecord::Migration
  def change
	add_column :share_prizes, :status, :integer,:default => 0

  end
end
