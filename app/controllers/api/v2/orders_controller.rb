module Api
  module V2
    class OrdersController < Api::BaseController
      respond_to :json

      def index
        full_order_list = OrdersService.new(current_user).all_orders

        @all_orders = full_order_list.map{|order| Api::V2::OrderSerializer.new(order, root: false, scope: current_user)}

        render status: 200, json: @all_orders
      end

      def remove_order
        order = Order.find(params[:id])
        order.update_attributes(:is_cancel => 1)

        render status: 200 , json: { status: :ok, error: '' }

      end

    end


  end
end