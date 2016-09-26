module Api
  module V2
    class FavoritesController < Api::BaseController
      respond_to :json

      def index
        fav_locations = favorite_locations.map{|favorite| Api::V2::LocationSerializer.new(favorite, root: false, scope: current_user)}

        fav_menu_items = favorite_menu_items.map{|item| Api::V2::MenuItemSerializer.new(item, root: false, scope: current_user)}
       
        @favs = {locations: fav_locations, items: fav_menu_items}

        render status: 200, json: @favs

      end

      private

      def favorite_locations
        @fav_locations = FavoritesService.new(current_user).favorite_locations

      end

      def favorite_menu_items
        @fav_menu_items = FavoritesService.new(current_user).favorite_menu_items

      end
    end
  end
end
