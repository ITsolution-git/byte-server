class AddBuildMenuIdToItemFavourite < ActiveRecord::Migration
  def change
    add_column :item_favourites, :build_menu_id, :integer
  end
end
