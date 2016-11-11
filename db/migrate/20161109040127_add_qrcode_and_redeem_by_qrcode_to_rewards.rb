class AddQrcodeAndRedeemByQrcodeToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :redeem_by_qrcode, :boolean, default: false
  end
end
