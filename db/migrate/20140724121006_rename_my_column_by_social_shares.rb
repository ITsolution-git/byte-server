class RenameMyColumnBySocialShares < ActiveRecord::Migration
  def up
     rename_column :social_shares, :social_point_id, :location_id
  end

  def down
  end
end
