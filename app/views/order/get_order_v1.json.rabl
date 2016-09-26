object @order
  attributes :id, :total_tip,:tip_percent ,:location_id, :status, :is_paid, :receipt_no, :server_id, :tax, :current_tax, :store_no, :ticket, :fee, :service_fee, :service_fee_type
  attribute :get_order_date => "order_date"
  attribute :get_paid_date => "paid_date"

child @order_items => "order_items" do
    attributes :id, :item_name, :item_id, :category_id, :menu_id, :comment_id, :comment_text, :comment_order_item_id, :quantity, :note, :use_point, :price, :redemption_value, :status, :rating, :prize_id, :share_prize_id, :is_prize_item

    child :order_item_options => "order_item_options" do
        attributes :id, :order_item_id, :item_option_addon_id, :item_option_addon_name, :status, :quantity
        attribute :display_price_with_float_format => "price"
    end
end

child @server => "server" do
  attributes :id, :name, :is_favorite
  node :avatar do |ser|
    ser.avatar.fullpath if ser.avatar
  end
end
