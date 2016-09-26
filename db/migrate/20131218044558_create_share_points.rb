class CreateSharePoints < ActiveRecord::Migration
  def change
    create_table :share_points do |t|
      t.integer :friendships_id
      t.integer :location_id
      t.float :points

      t.timestamps
    end
  end
end
