class AddIsPrizeItemToOrderItem < ActiveRecord::Migration
  def self.up
    OrderItem.reset_column_information
    unless OrderItem.column_names.include?('is_prize_item')
      add_column :order_items, :is_prize_item, :integer, :default => 0
    end
  end

  def self.down
    OrderItem.reset_column_information
    if OrderItem.column_names.include?('is_prize_item')
      remove_column(:order_items, :is_prize_item)
    end
  end
end
