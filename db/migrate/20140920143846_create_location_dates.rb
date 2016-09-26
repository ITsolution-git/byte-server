class CreateLocationDates < ActiveRecord::Migration
  def change
    if !ActiveRecord::Base.connection.table_exists? 'location_dates'
      create_table :location_dates do |t|
        t.string :time_from
        t.string :time_to
        t.string :day
        t.integer :location_id
        t.timestamps
      end
    end  
  end
end
