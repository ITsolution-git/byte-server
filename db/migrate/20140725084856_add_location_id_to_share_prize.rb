class AddLocationIdToSharePrize < ActiveRecord::Migration
  def change
  		add_column :share_prizes, :location_id, :integer
  end
end
