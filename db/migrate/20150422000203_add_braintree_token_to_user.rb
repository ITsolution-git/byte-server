class AddBraintreeTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :braintree_token, :string
  end
end
