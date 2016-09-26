class CreateItems < ActiveRecord::Migration
  def up
  	create_table :items do |t|
      t.integer :location_id
      t.string  :name
      t.float   :price
      t.text    :description
      t.integer :item_grade
      t.column :rating, :decimal, :precision=> 2, :scale=>1
      t.text :alert_type
      t.text :special_message
      t.text :ingredients
      t.timestamps
    end
  end

  def down
    drop_table :items
  end
end
