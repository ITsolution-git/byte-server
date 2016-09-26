module Api
  module V2
    class OrderSerializer < ActiveModel::Serializer
      attributes :id, :tax, :is_paid, :location_id, :location_name, :location_logo, :order_date, :paid_date, :ticket,
                 :receipt_no, :is_refunded, :pickup_time, :status, :tip_percent, :order_items
    #order_items, order_date

      def order_date
        object.updated_at
      end

      def location_name
        location = object.location

        if location.present?
          location.name
        end
      end

      def location_logo
        location = object.location

        if location.present?
          location.logo.try(:url)
        end
      end

      def order_items
        ordered_items = object.order_items
        #ordered_items = ordered_items.map{|order_item| Api::V2::OrderItemSerializer.new(order_item, root: false, scope: scope)}
      end
    end
  end
end
