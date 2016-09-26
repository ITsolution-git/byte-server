class CreateAppService < ActiveRecord::Migration
  def up
  	create_table :app_services do |t|
      t.string  :name
      t.float  :price
      t.string  :unit
      t.integer  :limit
      t.boolean  :active
      t.timestamps
    end
  end

  def down
  	drop_table :app_services
  end
end
