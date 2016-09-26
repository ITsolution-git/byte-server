class RemoveTheLevelups < ActiveRecord::Migration
  def up
    drop_table :the_level_ups
  end

  def down
    create_table :the_level_ups do |t|
      t.integer :app_id
      t.string :api_key
      t.string :client_secret
      t.string :app_access_token
      t.timestamps
    end
  end
end
