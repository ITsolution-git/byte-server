class ChangePointsToFloat < ActiveRecord::Migration
  def up
    change_column :notifications, :points, :float,:default=>0
  end

  def down
  end
end
