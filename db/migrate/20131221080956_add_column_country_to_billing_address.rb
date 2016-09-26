class AddColumnCountryToBillingAddress < ActiveRecord::Migration
  def change
  	 add_column :billing_addresses,:country,:string
  end
end
