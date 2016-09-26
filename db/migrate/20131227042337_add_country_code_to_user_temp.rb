class AddCountryCodeToUserTemp < ActiveRecord::Migration
  def change
    add_column :user_temps, :billing_address_country_code, :string
  end
end
