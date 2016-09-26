class ChangeIsPaidToIntegerFromOrder < ActiveRecord::Migration
  def up
  	change_column :orders, :is_paid, :integer,:default=>0
  end

  def down
  end
end
