class ConsolidateRewardPointsFields < ActiveRecord::Migration
  
  # WARNING: This is a destructive migration!
  # It permanently deletes the reward_points values from menus and items,
  # and the category_points values from categories.

  def up
    # NOTE: 'we want to use "grade" rather than "rate" when talking to the user"'
    
    add_column :locations, :points_awarded_for_grade, :integer, default: 0 # Zero was the programmatic default for reward_points in the Menu model

    execute <<-SQL
      UPDATE locations AS location, menus AS menu
      SET location.points_awarded_for_grade = menu.reward_points
      WHERE location.id = menu.location_id
    SQL

    remove_column :menus, :reward_points
    remove_column :items, :reward_points
  end

  def down

    add_column :menus, :reward_points, :integer, :default => 1 # This was the original default
    add_column :items, :reward_points, :integer
    add_column :categories, :category_points, :integer

    execute <<-SQL
      UPDATE menus AS menu, locations AS location
      SET menu.reward_points = location.points_awarded_for_grade
      WHERE menu.location_id = location.id
    SQL

    execute <<-SQL
      UPDATE items AS item, locations AS location
      SET item.reward_points = location.points_awarded_for_grade
      WHERE item.location_id = location.id
    SQL

    execute <<-SQL
      UPDATE categories AS category, locations AS location
      SET category.category_points = location.points_awarded_for_grade
      WHERE category.location_id = location.id
    SQL

    remove_column :locations, :points_awarded_for_grade
  end
end
