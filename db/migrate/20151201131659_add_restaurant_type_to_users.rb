class AddRestaurantTypeToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :restaurant_type, :string
  end
end
