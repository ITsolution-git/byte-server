class AddQrcodeAndRedeemByQrcodeToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :qrcode, :string
    add_column :rewards, :redeem_by_qrcode, :boolean, default: false
  end
end
