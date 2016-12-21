class CreateFundraisers < ActiveRecord::Migration
  def change
    create_table :fundraisers do |t|
      t.string :fundraiser_name
      t.string :name
      t.string :url
      t.integer :status
      t.string :url
      t.string :phone
      t.string :email
      t.string :alt_email
      t.string :address
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :credit_card_type
      t.string :credit_card_number
      t.string :credit_card_expiration_date
      t.string :credit_card_security_code

      t.timestamps
    end
  end
end
