class CreateLocations < ActiveRecord::Migration
  def up
  	create_table :locations do |t|
      t.string :name
      t.string :address
      t.float  :lat
      t.float  :long
      t.column :rating, :decimal, :precision=> 2, :scale=>1
      t.string :redemption_password
      t.string :city
      t.string :state
      t.string :country
      t.string :logo
      t.string :slug
      t.string :zip
      t.string :phone
      t.string :url
      t.integer :owner_id
      t.float :tax
      t.string :bio
      t.integer :global
      t.string :time_from
      t.string :time_to
      t.timestamps
    end
  end

  def down
  	drop_table :locations
  end
end
