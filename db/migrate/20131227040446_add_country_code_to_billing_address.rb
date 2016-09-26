class AddCountryCodeToBillingAddress < ActiveRecord::Migration
  def change
    add_column :billing_addresses, :country_code, :string
  end
end
