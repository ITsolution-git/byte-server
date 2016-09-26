class AddBuildIdToItemComment < ActiveRecord::Migration
  def change
    add_column :item_comments, :build_menu_id, :integer
    remove_column :item_comments, :item_id
  end
end
