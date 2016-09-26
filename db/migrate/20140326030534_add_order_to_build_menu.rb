class AddOrderToBuildMenu < ActiveRecord::Migration
  def change
    add_column :build_menus, :category_sequence, :integer, {default: 1}
    add_column :build_menus, :item_sequence, :integer, {default: 1}
  end
end
