class CreateMenus < ActiveRecord::Migration
  def up
  	create_table :menus do |t|
      t.column :location_id, :integer
      t.column :name, :string
      t.column  :reward_points, :integer,:default=>1
      t.column :rating_grade,:integer
      t.column :publish_status,:integer
      t.column :publish_start_date,:datetime
      t.column :menu_type_id,:integer
      t.column :repeat_on,:string
      t.column :publish_email,:string
      t.timestamps
    end
  end

  def down
  	drop_table :menus
  end
end
