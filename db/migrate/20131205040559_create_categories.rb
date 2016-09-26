class CreateCategories < ActiveRecord::Migration
  def up
  	create_table :categories do |t|
      t.string  :name
      t.integer  :location_id
      t.integer  :category_points
      t.timestamps
    end
  end

  def down
    drop_table :categories
  end
end
