class CreateLocationComments < ActiveRecord::Migration
  def up
  	create_table :location_comments do |t|
      t.integer :location_id
      t.integer :user_id
      t.text    :text
      t.integer :rating
      t.timestamps
    end
  end

  def down
    drop_table :location_comments
  end
end
