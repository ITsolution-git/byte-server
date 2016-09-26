class ChangeFavouriteToIntegerFromServerFavourite < ActiveRecord::Migration
  def up
    change_column :server_favourites, :favourite, :integer,:default=>0
  end

  def down
  end
end
