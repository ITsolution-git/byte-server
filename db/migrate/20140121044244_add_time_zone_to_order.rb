class AddTimeZoneToOrder < ActiveRecord::Migration
  def change
  	add_column :orders, :timezone, :string
  end
end
