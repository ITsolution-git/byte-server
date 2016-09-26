class AddFromShareToSharePrizes < ActiveRecord::Migration
  def change
    add_column :share_prizes, :from_share, :string
  end
end
