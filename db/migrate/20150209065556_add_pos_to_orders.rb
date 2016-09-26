class AddPosToOrders < ActiveRecord::Migration
  def self.up
    Order.reset_column_information
    unless Order.column_names.include?('pos')
      add_column :orders, :pos, :boolean, :default => 0
    end
  end

  def self.down
    Order.reset_column_information
    if Order.column_names.include?('pos')
      remove_column(:orders, :pos)
    end
  end

end
