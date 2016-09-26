module Api
  module V2
    class OrderItemSerializer < ActiveModel::Serializer
      attributes :id, :category_id, :is_prize_item, :item_id, :item_name, :menu_id, :note, :price, :prize_id,
                 :quantity, :rating, :redemption_value, :order_item_options, :is_favourite

      def item_name
        object.item.name
      end

      def category_id
        relevant_categories.map{|category| category.id}.first
      end

      def relevant_categories
        object_menus = object.item.menus

        # We are only interested in return the categories that belong
        # to published menus.

        relevant_categories = object.item.categories.select do |category|

          # We only look at menus that are both owned by the category
          # and by the object. To do this we use #& for set intersection.

          relevant_menus = category.menus & object_menus
          relevant_menus.reduce(false) do |accumulator, menu|
            menu.published? || accumulator
          end
        end
      end

      def is_favourite
        favorites = object.item.item_favourites.where(user_id: scope.id)
        favorites.present? && favorites.any?{|favorite| favorite.favourite == 1}
      end

      def menu_id
        object.item.menus
            .select{|menu| menu.published?}
            .map{|menu| menu.id}.first
      end

      def rating
        object.item.average_rating.ceil
      end

      def order_item_options
        ordered_items_options = object.order_item_options
        ordered_items_options = ordered_items_options.map{|order_item_option| Api::V2::OrderItemOptionSerializer.new(order_item_option, root: false, scope: scope)}
      end
    end
  end
end
