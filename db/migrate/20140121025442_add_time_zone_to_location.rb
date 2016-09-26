class AddTimeZoneToLocation < ActiveRecord::Migration
  def change
  	add_column :locations, :timezone, :string
  end
end
