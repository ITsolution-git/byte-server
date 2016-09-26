class CreateInfoAvatars < ActiveRecord::Migration
  def change
    create_table :info_avatars do |t|
      t.integer :info_id
      t.string :image
      t.string :info_token

      t.timestamps
    end
  end
end
