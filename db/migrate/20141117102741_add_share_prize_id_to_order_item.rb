class AddSharePrizeIdToOrderItem < ActiveRecord::Migration
  def self.up
    OrderItem.reset_column_information
    unless OrderItem.column_names.include?('share_prize_id')
      add_column :order_items, :share_prize_id, :integer
    end
  end

  def self.down
    OrderItem.reset_column_information
    if OrderItem.column_names.include?('share_prize_id')
      remove_column(:order_items, :share_prize_id)
    end
  end
end
