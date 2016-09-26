class OrderItem < ActiveRecord::Base
  attr_accessible \
    :build_menu_id,
    :order_id,
    :quantity,
    :note,
    :use_point,
    :status,
    :paid_type,
    :price,
    :redemption_value,
    :rating,:comment,
    :prize_id,
    :share_prize_id,
    :is_prize_item,
    :item_id

  belongs_to :build_menu
  belongs_to :order
  belongs_to :item
  belongs_to :combo_item
  has_many :order_item_combos, dependent: :destroy
  has_many :order_item_options, dependent: :destroy

  attr_accessible :build_menu_id, :order_id, :quantity, :note, :use_point,
                  :status, :paid_type, :price, :redemption_value, :rating, :comment

  def get_price(order)
    return order.tax
  end

  def self.add_new_item(item, order)
    # Add item to order, If combo type is PMI, we add item's combo_items (2 items) to order
    # If combo type is GMI, we have two cases
    # First case : user add an item to when they order an item => item['item_combo_items'] is empty
    # Second case : user update their order (they want to add item to order ordered) => item['item_combo_items'] isn't empty
    #  => add combo items to order
    ActiveRecord::Base.transaction do
      build_menu = BuildMenu.where(item_id: item['item_id'],
                                   menu_id: item['menu_id'],
                                   category_id: item['category_id'],
                                   active: ACTIVE).first
      # Create an order item
      order_item = order.order_items.build(combo_item_id: item['combo_item_id'],
                                           quantity: item['quantity'],
                                           build_menu_id: build_menu.id,
                                           item_id: item['item_id'],
                                           price: item['price'],
                                           note: item['note'],
                                           redemption_value: item['redemption_value'])
      order_item.save!

      OrderItemCombo.add_combo_items(order_item, item['order_item_combos']) if item['order_item_combos'].present?
      order_item
    end
  end

  def self.update_items(order_items, order, is_paid)
    order_items.each do |i|
      if i['is_delete'] == 1
        self.delete_item(i)
      elsif i['is_delete'] == 0
        self.update_an_item(i, order.status, is_paid)
      end
    end
    return true
  end

  def self.update_an_item(order_item, order_status, is_paid)
      current_order_item = OrderItem.where(id: order_item['id']).first
      if current_order_item.present?
        current_order_item.update_attributes!(quantity: order_item['quantity'].to_i,
                                              note: order_item['note'],
                                              use_point: order_item['use_point'].to_i,
                                              status: order_item['status'])
      end
      OrderItemCombo.update_combo_items(current_order_item, order_item['order_item_combos'], UPDATE_ORDER)
  end

  def self.delete_item(item)
    @order_item = self.where(id: item['id']).first
    @order_item.destroy if @order_item
  end

  # :skippit:
  def self.get_items_current_order(order_id)
    sql = "select oi.id, IFNULL(ic.id,0) as order_item_comment_id, bm.menu_id  as menu_id, i.price, i.id as item_id, i.name as item_name,
           IFNULL(ic.rating,0) as rating,  oi.created_at,ic.text as order_item_comment,
           bm.category_id, bm.menu_id,oi.quantity,oi.note,oi.use_point,oi.redemption_value,oi.status, oi.id as order_item_id,
           oi.combo_item_id
           from orders o
           join order_items oi on o.id = oi.order_id
           join build_menus bm on bm.id = oi.build_menu_id
           left join item_comments ic on ic.build_menu_id=bm.id and ic.order_item_id=oi.id
           join menus m on m.id = bm.menu_id
           join items i on bm.item_id = i.id
           where o.id = #{order_id} and ((m.publish_status = 2 and oi.status = 0) or oi.status = 1) and bm.active = #{ACTIVE}
           order by oi.created_at"
    return self.find_by_sql(sql)
  end
  # :skippit:

  # :skippit:
  def self.get_items_order_detail(order_id)
    sql = "select DISTINCT IFNULL(ic.id,0) as order_item_comment_id, ic.text as order_item_comment,
            IFNULL(ic.order_item_id,0) as order_item_id, oi.id, i.price,i.id as item_id, i.name as item_name,
            IFNULL(ic.rating,0) as rating, bm.category_id,bm.menu_id,oi.quantity, oi.created_at,
            oi.note,oi.use_point,oi.redemption_value,oi.status, oi.combo_item_id
           from orders o
           join order_items oi on o.id = oi.order_id
           join build_menus bm on bm.id = oi.build_menu_id
           left join item_comments ic on ic.build_menu_id=bm.id and ic.order_item_id=oi.id
           join items i on bm.item_id = i.id
           where o.id = #{order_id} and bm.active = #{ACTIVE}
           order by oi.created_at"
    return self.find_by_sql(sql)
  end
  # :skippit:

  # Begin - Implement the new version of order feature
  def self.add_new_item_v1(item, order)
    ActiveRecord::Base.transaction do
      build_menu = BuildMenu.where(item_id: item['item_id'],
                                   menu_id: item['menu_id'],
                                   category_id: item['category_id'],
                                   active: ACTIVE).first

      order_item = order.order_items.build(quantity: item['quantity'],
                                           build_menu_id: build_menu.try(:id),
                                           item_id: item['item_id'],
                                           price: item['price'],
                                           note: item['note'],
                                           redemption_value: item['redemption_value'])
      order_item.save!
      if item['order_item_options'].present? && item['order_item_options'].present?
        OrderItemOption.add_item_options(order_item, item['order_item_options'])
      end

      order_item
    end
  end

  def self.update_items_v1(order_items)
    order_items.each do |i|
      item = self.find(i['id'])
      if i['is_deleted'].to_i == 0
        prize_id = nil
        share_prize_id = nil
        prize_id = i['prize_id'] if i['prize_id'].to_i != 0
        if item['is_prize_item'].to_i == 1
          share_prize_id = i['share_prize_id'].to_i if i['share_prize_id']
        end
        item.update_attributes!(
          :quantity => i['quantity'].to_i,
          :note => i['note'],
          :use_point => i['use_point'].to_i,
          :status => i['status'],
          :prize_id => prize_id,
          :share_prize_id => share_prize_id,
          :is_prize_item => item['is_prize_item'].to_i
        )
        OrderItemOption.update_item_options(item, i['order_item_options'].to_a)
      else
        item.destroy
      end
    end
  end

  # :skippit:
  def self.get_items(order_id)
    sql = "select DISTINCT IFNULL(ic.id, 0) as comment_id, ic.text as comment_text,
              IFNULL(ic.order_item_id, 0) as comment_order_item_id, oi.id, oi.price,i.id as item_id, i.name as item_name,
              IFNULL(ic.rating,0) as rating, bm.category_id,bm.menu_id,oi.quantity, oi.created_at,
              oi.note, oi.use_point, oi.redemption_value, oi.status, IFNULL(oi.prize_id, 0) as prize_id,
              IFNULL(oi.share_prize_id, 0) as share_prize_id, oi.is_prize_item
           from orders o
           join order_items oi on o.id = oi.order_id
           join build_menus bm on bm.id = oi.build_menu_id
           left join item_comments ic on ic.build_menu_id = bm.id and ic.order_item_id = oi.id
           join items i on bm.item_id = i.id
           where o.id = #{order_id} and bm.active = #{ACTIVE}
           order by oi.created_at"
    return self.find_by_sql(sql)
  end
  # :skippit:

  # :skippit:
  def self.get_items_of_current_order(order_id)
    sql = "select oi.id, IFNULL(ic.id, 0) as comment_id, ic.text as comment_text, IFNULL(ic.order_item_id, 0) as comment_order_item_id, bm.menu_id  as menu_id, oi.price,
            i.id as item_id, i.name as item_name, IFNULL(ic.rating, 0) as rating, oi.created_at, bm.category_id, bm.menu_id, oi.quantity, oi.note,
            oi.use_point, oi.redemption_value, oi.status, IFNULL(oi.prize_id, 0) as prize_id, IFNULL(oi.share_prize_id, 0) as share_prize_id,
            oi.is_prize_item
           from orders o
           join order_items oi on o.id = oi.order_id
           join build_menus bm on bm.id = oi.build_menu_id
           left join item_comments ic on ic.build_menu_id=bm.id and ic.order_item_id = oi.id
           join menus m on m.id = bm.menu_id
           join items i on bm.item_id = i.id
           where o.id = #{order_id} and ((m.publish_status = 2 and oi.status = 0) or oi.status = 1) and bm.active = #{ACTIVE}
           order by oi.created_at"
    return self.find_by_sql(sql)
  end
  # :skippit:
  # End - Implement the new version of order feature
end
