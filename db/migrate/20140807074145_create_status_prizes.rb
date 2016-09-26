class CreateStatusPrizes < ActiveRecord::Migration
  def change
    create_table :status_prizes do |t|
      t.string :name
      t.integer :location_id

      t.timestamps
    end
  end
end
