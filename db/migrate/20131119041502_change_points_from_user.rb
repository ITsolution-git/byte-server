class ChangePointsFromUser < ActiveRecord::Migration
  def up
    change_column :users, :points, :float
  end

  def down
  end
end
