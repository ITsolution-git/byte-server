class AddTypeToComboItem < ActiveRecord::Migration
  def change
    add_column :combo_items, :combo_type, :string
  end
end
