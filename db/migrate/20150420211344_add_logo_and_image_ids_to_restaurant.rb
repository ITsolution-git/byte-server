class AddLogoAndImageIdsToRestaurant < ActiveRecord::Migration
  def up
    add_column :locations, :logo_id, :integer unless column_exists? :locations, :logo_id
  end

  def down
    remove_column :locations, :logo_id if column_exists? :locations, :logo_id
  end
end
