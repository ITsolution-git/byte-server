class ChangeDefaultColumnPoint < ActiveRecord::Migration
  def up
    change_column :users, :points, :integer, :default => 0
  end

  def down
  end
end
