class CreateCustomersLocations < ActiveRecord::Migration
  def change
    create_table :customers_locations do |t|
      t.integer :location_id
      t.integer :user_id
      t.integer :suspend, :default => 0

      t.timestamps
    end
  end
end
