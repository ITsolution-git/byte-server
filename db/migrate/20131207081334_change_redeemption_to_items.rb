class ChangeRedeemptionToItems < ActiveRecord::Migration
  def change
    add_column :items, :redemption_value, :integer
    remove_column :items, :redeemtion_value
  end
end
