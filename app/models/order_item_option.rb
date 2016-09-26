class OrderItemOption < ActiveRecord::Base
  attr_accessible :order_item_id, :item_option_addon_id, :price, :quantity, :status, :item_option_addon_name

  belongs_to :order_item
  belongs_to :item_option_addon

  def display_price_with_float_format
    self.price.to_f
  end

  def self.add_item_options(order_item, options)
    ActiveRecord::Base.transaction do
      options.each do |option|
        self.add_option(order_item, option)
      end
    end
  end

  def self.add_option(order_item, option)
    OrderItemOption.transaction do
      addon = ItemOptionAddon.find_by_id(option['item_option_addon_id'])
      addon_price = option['price']
      order_item_option = order_item.order_item_options.build
      order_item_option.item_option_addon_id = option['item_option_addon_id']
      order_item_option.item_option_addon_name = ItemOptionAddon.where(id: option['item_option_addon_id']).first.try(:name).to_s
      order_item_option.quantity = option['quantity']
      addon_price = addon.price if !addon.nil?
      order_item_option.price = addon_price
      order_item_option.save!
    end
  end

  def self.update_item_options(order_item, options)
    order_item.order_item_options.destroy_all
    options.each do |i|
      self.add_option(order_item, i)
=begin
      else
        option = OrderItemOption.find_by_id(i['id'])
        unless option.nil?
          if i['is_deleted'] == 1
            option.destroy
          else
            option.update_attributes(
              :quantity => i['quantity'],
              :item_option_addon_id => i['item_option_addon_id'],
              :status => order_item.status
            )
          end
        end
      end
=end
    end
  end
end
