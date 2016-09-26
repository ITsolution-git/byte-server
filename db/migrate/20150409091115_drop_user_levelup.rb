class DropUserLevelup < ActiveRecord::Migration
  def up
    drop_table :user_levelups
  end

  def down
    create_table :user_levelups do |t|
      t.integer :user_id
      t.integer :permission_request_id
      t.string :role
      t.string :email
      t.string :password
      t.string :access_token

      t.timestamps
    end
  end
end
