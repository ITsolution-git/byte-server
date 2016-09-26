class RemoveBillingAddresses < ActiveRecord::Migration
  def change
  	drop_table :billing_addresses
  end
end
