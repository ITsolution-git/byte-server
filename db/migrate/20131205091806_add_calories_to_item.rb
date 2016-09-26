class AddCaloriesToItem < ActiveRecord::Migration
  def change
    add_column :items, :calories, :integer
    add_column :items, :reward_points, :integer
  end
end
