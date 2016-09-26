class OrdersService

  def initialize(user)
    @user = user
  end

  def all_orders
    Order
        .includes(:order_items)
        .where(:user_id => @user.id)
        .where(:is_cancel => 0)
  end
end