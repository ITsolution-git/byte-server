class CreateBuildMenus < ActiveRecord::Migration
  def up
  	create_table :build_menus do |t|
      t.integer  :item_id
      t.integer  :menu_id
      t.integer  :category_id
      t.timestamps
    end
  end

  def down
    drop_table :build_menus
  end
end
