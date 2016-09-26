class CreateMenuServers < ActiveRecord::Migration
  def up
  	create_table :menu_servers do |t|
      t.integer  :menu_id
      t.integer :server_id
      t.timestamps
    end
  end

  def down
  	drop_table :menu_servers
  end
end
