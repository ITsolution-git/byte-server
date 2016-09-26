class AddCopiedMenusCntToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :copied_menus_cnt, :integer, default: 0
  end
end
