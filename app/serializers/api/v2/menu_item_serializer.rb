module Api
  module V2
    class MenuItemSerializer < ActiveModel::Serializer
      attributes :id, :menu_id, :category_id, :name, :price, :description,
        :calories, :special_message, :favorited, :favorited_total, :location_id, :reviews,
        :redemption_value, :reward_points, :rating, :rating_total, :food_types,
        :modifier_categories, :images, :keys, :favorited_date, :location_name, :category_names

      def menu_id
        object.menus
          .select{|menu| menu.published?}
          .map{|menu| menu.id}.first
      end

      def category_id
        relevant_categories.map{|category| category.id}.first
      end


      def relevant_categories
        object_menus = object.menus

        # We are only interested in return the categories that belong
        # to published menus.

        relevant_categories = object.categories.select do |category|

          # We only look at menus that are both owned by the category
          # and by the object. To do this we use #& for set intersection.

          relevant_menus = category.menus & object_menus
          relevant_menus.reduce(false) do |accumulator, menu|
            menu.published? || accumulator
          end
        end
      end

      def category_names
        relevant_categories.map{|category| category.name}
      end

      def rating
        object.average_rating.ceil
      end

      def rating_total
        object.ratings_count
      end

      def favorited
        favorites = object.item_favourites.where(user_id: scope.id)
        favorites.present? && favorites.any?{|favorite| favorite.favourite == 1}
      end

      def favorited_total
        object.item_favourites.where(favourite: 1).count
      end

      def reviews
        object.review
      end

      def food_types
        if object.item_type.present?
          [{name: object.item_type.name }]
        else
          []
        end
      end

      def modifier_categories
        object.item_options.map do |item_option|
          {
            id: item_option.id,
            name: item_option.name,
            select_only_one: item_option.only_select_one == 1,
            modifiers: item_option.item_option_addons.map do |addon|
              {
                id: addon.id,
                name: addon.name,
                price: addon.price,
                is_selected: addon.is_selected
              }
            end
          }
        end
      end

      def images
        object.images.map do |image|
          {
            image: image.url
          }
        end
      end

      def keys
        object.item_keys.map do |key|
          {
            id: key.id,
            name: key.name,
            description: key.description,
            image: key.image.present? ? key.image.url : nil
          }
        end
      end

      def favorited_date
        favorite = object.item_favourites.where(user_id: scope.id).first


        if favorite.present?
          favorite.updated_at
        end
      end

      def location_name
        object.location.name
      end
    end
  end
end
