class ChangePriceColumnToDecimal < ActiveRecord::Migration
  def up
    change_column :items, :price, :decimal, :precision=> 5, :scale=>2
  end

  def down
  end
end
