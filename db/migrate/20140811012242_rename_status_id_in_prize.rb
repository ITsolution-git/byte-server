class RenameStatusIdInPrize < ActiveRecord::Migration
  def up
  	 rename_column :prizes, :status_id, :status_prize_id
  end

  def down
  end
end
