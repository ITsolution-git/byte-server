class AddLevelupOrderIdToOrder < ActiveRecord::Migration
  def self.up
    Order.reset_column_information
    unless Order.column_names.include?('levelup_order_id')
      add_column :orders, :levelup_order_id, :string
    end
  end

  def self.down
    Order.reset_column_information
    if Order.column_names.include?('levelup_order_id')
      remove_column(:orders, :levelup_order_id)
    end
  end
end