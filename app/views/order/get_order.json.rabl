object @order
	attributes :id, :total_tip,:tip_percent ,:location_id, :status, :is_paid, :receipt_no, :server_id, :tax, :current_tax, :store_no, :fee
	attribute :get_order_date => "order_date"
	attribute :get_paid_date => "paid_date"

child @order_items => "order_items" do
    attributes :id, :order_item_comment_id, :order_item_comment, :category_id, :menu_id, :quantity, :note, :use_point, :price, :redemption_value, :status, :rating,
    :item_id, :item_name, :order_item_id, :combo_item_id

    child :order_item_combos => "order_item_combo" do
        attributes *OrderItemCombo.column_names - ['updated_at', 'created_at', 'build_menu_id'], :order_date
        node(:category_id) do |cate|
            cate.build_menu.get_category_id_by_buid_menu_id(cate.build_menu_id)
        end
        node(:menu_id) do |cate|
            cate.build_menu.get_menu_id_by_buid_menu_id(cate.build_menu_id)
        end
        child :item => "items" do
            attributes :id, :name
        end
    end
end


child @server => "server" do
	attributes :id, :name, :is_favorite
  node :avatar do |ser|
    ser.avatar.fullpath if ser.avatar
  end
end
