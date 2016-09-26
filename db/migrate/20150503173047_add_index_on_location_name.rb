class AddIndexOnLocationName < ActiveRecord::Migration
  def up
    add_index :locations, :name
    add_index :locations, :primary_cuisine
    add_index :locations, :secondary_cuisine
  end

  def down
    remove_index :locations, :name
    remove_index :locations, :primary_cuisine
    remove_index :locations, :secondary_cuisine
  end
end
