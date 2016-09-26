class AddQrCodeLevelUpToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :qrcode_levelup, :string
  end
end
