class CreateMenuTypes < ActiveRecord::Migration
  def up
  	create_table :menu_types do |t|
      t.string :name
      t.timestamps
    end
  end

  def down
  	drop_table :menu_types
  end
end
