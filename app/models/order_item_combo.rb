class OrderItemCombo < ActiveRecord::Base
  attr_accessible :order_item_id, :item_id, :build_menu_id, :note, :quantity, :price, :use_point, :redemption_value, :price, :status,:paid_quantity

  belongs_to :order_item
  belongs_to :item
  belongs_to :build_menu

  def order_date
    self.created_at.strftime("%m-%d-%Y %H:%M:%S")
  end

  def self.add_combo_items(order_item, combos)
    # add combo items of item selected to current order
    ActiveRecord::Base.transaction do
      combos.each do |combo|
        self.add_an_combo_item(order_item, combo)
      end
    end
  end

  def self.update_combo_items(order_item, combos, feature)
      combos.each do |c|
        if c['id'].to_i == -1
          self.add_an_combo_item(order_item, c)
        else
          order_item_combo = OrderItemCombo.find(c['id'])
          if c['is_delete'] == 1
            order_item_combo.destroy
          else
            if feature == UPDATE_ORDER
              order_item_combo.update_attributes!(:quantity => c['quantity'], :price => c['price'],\
                :note => c['note'], :status => order_item.status, :use_point => c['use_point'],:paid_quantity => c['paid_quantity'])
            end
            if feature == UPDATE_ORDER_ITEM
              order_item_combo.update_attributes!(:quantity => c['quantity'], :price => c['price'],\
                :note => c['note'], :status => order_item.status, :redemption_value => c['redemption_value'], :use_point => 0, :paid_quantity => c['paid_quantity'])
            end
          end
        end
      end
  end

  def self.add_an_combo_item(order_item, combo)
    OrderItemCombo.transaction do
     # combo_type = order_item.combo_item.combo_type
      combo_type = combo['type']
      puts "COMBO_TYPE: #{combo_type}"
      puts "??? item", combo['item_id']
      build_menu = BuildMenu.find_by_item_id_and_menu_id_and_category_id_and_active(combo['item_id'],\
        combo['menu_id'], combo['category_id'], ACTIVE)
      order_item_combo = order_item.order_item_combos.build
      order_item_combo.quantity = combo['quantity']
      order_item_combo.build_menu_id = build_menu.id
      order_item_combo.item_id = combo['item_id']
      order_item_combo.price = combo['price']
      order_item_combo.note = combo['note']
      order_item_combo.redemption_value = combo['redemption_value']
      order_item_combo.max_quantity = order_item.combo_item.combo_item_categories\
        .get_quantity(combo['category_id'], order_item.combo_item_id).first.quantity if combo_type == GMI
      order_item_combo.save!
    end
  end
end