class AddIndexToBuildMenu < ActiveRecord::Migration
  def change
    add_index :build_menus, :item_id
  end
end
