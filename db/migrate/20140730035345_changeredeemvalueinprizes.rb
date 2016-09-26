class Changeredeemvalueinprizes < ActiveRecord::Migration
  def up
    change_column :prizes, :redeem_value, :integer
  end

  def down
  end
end
