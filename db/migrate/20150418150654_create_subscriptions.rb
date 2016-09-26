class CreateSubscriptions < ActiveRecord::Migration
  def up
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :subscription_id

      t.timestamps
    end
  end

  def down
    drop_table :subscriptions
  end
end
