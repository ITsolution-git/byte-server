class AddIndexToItemComment < ActiveRecord::Migration
  def change
    add_index :item_comments, :build_menu_id
  end
end
