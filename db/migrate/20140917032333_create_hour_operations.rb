class CreateHourOperations < ActiveRecord::Migration
  def change
    create_table :hour_operations do |t|
      t.integer :day
      t.string :time_open
      t.string :tim_close
      t.integer :location_id
      t.integer :group_hour

      t.timestamps
    end
  end
end
