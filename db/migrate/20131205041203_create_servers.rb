class CreateServers < ActiveRecord::Migration
  def up
  	create_table :servers do |t|
      t.column :name, :string
      t.column :avatar, :string
      t.column :location_id, :string
      t.column :rating, :decimal, :precision=> 2, :scale=>1 
      t.timestamps
    end
  end

  def down
  	drop_table :servers
  end
end
