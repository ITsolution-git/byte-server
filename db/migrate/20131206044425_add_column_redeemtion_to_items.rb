class AddColumnRedeemtionToItems < ActiveRecord::Migration
  def change
  	add_column :items, :redeemtion_value, :integer
  end
end
