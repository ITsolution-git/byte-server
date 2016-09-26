class PaymentsController < ApplicationController

  before_filter :authenticate_user_json
  def create
    order = Order.find params[:order_id]
    result = order.pay_order(params[:amount], params[:payment_token])
    if result[:status] == 'success'
      render json: result, status: :ok
    else
      render json: result, status: :bad_request
    end
  end

  # Refunds/voids the order. For now we have decided we do not want to ever delete these orders.
  def destroy
    order = Order.find(params[:id])
    response = order.refund
    if response['status'] == 'failed'
      flash[:notice] = 'Refund failed. Please try again shortly'
    else
      flash[:notice] = 'You have successfully refunded this order.'
    end
    respond_to do |format|
      format.html {redirect_to restaurant_orders_restaurant_order_index_path}
      format.json {render json: response}
    end
  end
end
