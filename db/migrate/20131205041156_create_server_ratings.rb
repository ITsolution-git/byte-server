class CreateServerRatings < ActiveRecord::Migration
  def up
  	create_table :server_ratings do |t|
      t.column :server_id, :integer
      t.column :user_id, :integer
      t.column :rating, :integer
      t.timestamps
    end
  end

  def down
  	drop_table :server_ratings
  end
end
