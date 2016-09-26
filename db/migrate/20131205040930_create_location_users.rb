class CreateLocationUsers < ActiveRecord::Migration
  def up
  	create_table :locations_users,:id=>false do |t|
      t.column :location_id, :integer
      t.column :user_id, :integer
      t.column :check_in,:integer
      t.column :check_in_count,:integer
      t.column :check_in_at,:datetime
      
    end
  end

  def down
  	drop_table :locations_users
  end
end
