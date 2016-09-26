class FavoritesService

  def initialize(user)
    @user = user
  end

  def favorite_locations
    Location
      .includes(:location_favourites, :menus)
      .where(location_favourites: {user_id: @user.id, favourite: 1}, menus: {publish_status: 2})
  end

  def favorite_menu_items
    Item
      .includes(:item_favourites)
      .where(item_favourites: {user_id: @user.id, favourite: 1})
  end
end