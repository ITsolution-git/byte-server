class CreateItemTypes < ActiveRecord::Migration
  def up
  	create_table :item_types do |t|
      t.string  :name
      t.timestamps
    end
  end

  def down
  	drop_table :item_types
  end
end
