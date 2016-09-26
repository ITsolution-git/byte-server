class AddBuildMenuIdToItemNexttime < ActiveRecord::Migration
  def change
    add_column :item_nexttimes, :build_menu_id, :integer
  end
end
