module Api
  module V2
    class OrderItemOptionSerializer < ActiveModel::Serializer
      attributes :item_option_addon_id, :item_option_addon_name, :price, :quantity

    end
  end
end
