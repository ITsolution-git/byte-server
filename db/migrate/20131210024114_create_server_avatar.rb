class CreateServerAvatar < ActiveRecord::Migration
  def change
    create_table :server_avatars do |t|
      t.integer :server_id
      t.string :image
      t.string :server_token
      t.timestamps
    end
  end
end
