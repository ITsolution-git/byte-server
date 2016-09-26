class AddGlobalToItemKeys < ActiveRecord::Migration
  def change
    add_column :item_keys, :is_global, :boolean
    add_index :item_keys, :is_global
  end
end
