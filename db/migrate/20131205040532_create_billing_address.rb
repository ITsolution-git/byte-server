class CreateBillingAddress < ActiveRecord::Migration
  def up
  	create_table :billing_addresses do |t|
      t.string  :address
      t.string  :city
      t.string  :state
      t.string  :zip
      t.integer  :credit_card_id
      t.timestamps
    end
  end

  def down
    drop_table :billing_addresses
  end
end
