class CreateFundraisersLocationsJoinTable < ActiveRecord::Migration
  def change

    create_table :fundraisers_locations do |t|
      t.integer :fundraiser_id
      t.integer :location_id
    end
  end
end
