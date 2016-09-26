class CreateUserTemps < ActiveRecord::Migration
  def change
    create_table :user_temps do |t|
      t.string :username
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :password
      t.string :location_name
      t.string :location_chain_name
      t.string :location_address
      t.string :location_country
      t.string :location_state
      t.string :location_city
      t.string :location_zip
      t.string :credit_card_type
      t.string :credit_card_number
      t.string :credit_card_expiration_date
      t.string :credit_card_security_code
      t.string :billing_address_address
      t.string :billing_address_country
      t.string :billing_address_state
      t.string :billing_address_city
      t.string :billing_address_zip

      t.timestamps
    end
  end
end
