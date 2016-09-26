class CreatePrizes < ActiveRecord::Migration
  def change
    create_table :prizes do |t|
      t.string :name
      t.float :redeem_value
      t.integer :location_id

      t.timestamps
    end
  end
end
