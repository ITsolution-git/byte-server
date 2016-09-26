class SetLimitToLatLngInLocation < ActiveRecord::Migration
  def up
    change_column :locations, :lat, :decimal, :precision => 15, :scale => 6
    change_column :locations, :long, :decimal, :precision => 15, :scale => 6
  end

  def down
  end
end
