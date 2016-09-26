class CreatePrizeRedeems < ActiveRecord::Migration
  def change
    create_table :prize_redeems do |t|
      t.integer :prize_id
      t.integer :user_id
      t.string :type

      t.timestamps
    end
  end
end
