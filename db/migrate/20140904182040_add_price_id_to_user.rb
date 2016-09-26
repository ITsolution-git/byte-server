class AddPriceIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :price_id, :integer
  end
end
