class CreateItemNexttimes < ActiveRecord::Migration
  def up
  	create_table :item_nexttimes do |t|
      t.integer  :item_id
      t.integer  :user_id
      t.boolean  :nexttime
      t.timestamps
    end
  end

  def down
    drop_table :item_nexttimes
  end
end
