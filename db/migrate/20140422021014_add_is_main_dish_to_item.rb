class AddIsMainDishToItem < ActiveRecord::Migration
  def change
    add_column :items, :is_main_dish, :boolean, default: false
  end
end
