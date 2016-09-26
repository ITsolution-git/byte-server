class CreateCheckins < ActiveRecord::Migration
  def change
    if !ActiveRecord::Base.connection.table_exists? 'checkins'
      create_table :checkins do |t|
        t.references :user
        t.references :location

        t.timestamps
      end
      add_index :checkins, :user_id
      add_index :checkins, :location_id
    end  
  end
end
