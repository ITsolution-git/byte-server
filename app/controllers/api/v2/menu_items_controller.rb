module Api
  module V2
    class MenuItemsController < Api::BaseController
      def show
        item = Item.find(params[:item_id])
        render json: item, serializer: Api::V2::MenuItemSerializer, root: false, scope: current_user
      end

      def find_by_tag
        item_tag = ItemTag.new params[:location_id]
        items = TagRulesService.new(params[:tags], item_tag).find_tags
        render json: items.map{|item| Api::V2::MenuItemSerializer.new(item, root: false, scope: current_user)}
      end

      def get_all_menuitems
        items = Item.where(:location_id => params[:location_id])
        render json: items.map{|item| Api::V2::MenuItemSerializer.new(item, root: false, scope: current_user)}
      end
    end
  end
end
