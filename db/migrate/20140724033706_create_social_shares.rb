class CreateSocialShares < ActiveRecord::Migration
  def change
    create_table :social_shares do |t|
      t.integer :social_point_id
      t.integer :user_id
      t.string :type

      t.timestamps
    end
  end
end
