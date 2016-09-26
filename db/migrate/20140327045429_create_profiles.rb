class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :account_number
      t.string :restaurant_name
      t.string :mailing_address
      t.string :mailing_city
      t.string :mailing_country
      t.string :mailing_zip
      t.integer :user_id

      t.timestamps
    end
  end
end
