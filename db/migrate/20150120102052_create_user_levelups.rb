class CreateUserLevelups < ActiveRecord::Migration
  def change
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
