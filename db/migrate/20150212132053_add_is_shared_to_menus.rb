class AddIsSharedToMenus < ActiveRecord::Migration
  def change
    add_column :menus, :is_shared, :boolean
  end
end
