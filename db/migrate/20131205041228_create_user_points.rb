class CreateUserPoints < ActiveRecord::Migration
  def up
  	create_table :user_points do |t|
      t.string :user_id
      t.string :point_type
      t.integer :location_id
      t.float :points
      t.integer :status
      t.integer :is_give
      t.timestamps
    end
  end

  def down
  	drop_table :user_points
  end
end
