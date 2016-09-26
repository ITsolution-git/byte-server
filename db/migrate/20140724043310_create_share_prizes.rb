class CreateSharePrizes < ActiveRecord::Migration
  def change
    create_table :share_prizes do |t|
      t.integer :prize_id
      t.integer :from_user
      t.integer :to_user
      t.string :token
      t.timestamps
    end
  end
end
