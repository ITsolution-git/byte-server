class CreateItemComments < ActiveRecord::Migration
  def up
  	create_table :item_comments do |t|
      t.integer  :item_id
      t.integer  :user_id
      t.text  :text
      t.float  :rating
      t.timestamps
    end
  end

  def down
    drop_table :item_comments
  end
end
