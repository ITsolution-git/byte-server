class CreateDinnerTypes < ActiveRecord::Migration
  def up
  	create_table :dinner_types do |t|
      t.integer  :location_id
      t.string  :types
      t.integer  :point
      t.integer  :key
      t.timestamps
    end
  end

  def down
    drop_table :dinner_types
  end
end
