class AddPaymentTypeAndUserStatusToOrder < ActiveRecord::Migration
  def self.up
    Order.reset_column_information
    unless Order.column_names.include?('payment_type')
      add_column :orders, :payment_type, :string
    end
  end

  def self.down
    Order.reset_column_information
    if Order.column_names.include?('payment_type')
      remove_column(:orders, :payment_type)
    end
  end
end