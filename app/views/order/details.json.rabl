object @orders
    attributes :id, :total_tip,:tip_percent,:total_tax,:receipt_no,:store_no,:is_paid, :sub_price, :total_price, :fee
		attribute :get_order_date => "order_date"
		attribute :get_paid_date => "paid_date"

child @order_items => "order_items" do
	attributes :id, :order_item_comment_id, :order_item_comment, :order_item_id, :price, :status,
        :quantity,:use_point,:note, :redemption_value,:rating, :combo_item_id, :menu_id,:category_id, :item_id,
        :item_name

    child :order_item_combos => "order_item_combo" do
        attributes *OrderItemCombo.column_names - ['created_at', 'updated_at', 'build_menu_id']

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
  node :avatar do |server|
    server.avatar.fullpath if server.avatar
  end
end
