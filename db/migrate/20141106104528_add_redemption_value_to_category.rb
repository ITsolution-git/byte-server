class AddRedemptionValueToCategory < ActiveRecord::Migration
  def self.up
    Category.reset_column_information
    unless Category.column_names.include?('redemption_value')
      add_column :categories, :redemption_value, :integer
    end
  end

  def self.down
    Category.reset_column_information
    if Category.column_names.include?('redemption_value')
      remove_column(:categories, :redemption_value)
    end
  end
end
