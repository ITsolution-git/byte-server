class AddZipAndLatAndLngToCity < ActiveRecord::Migration
  def change
    add_column :cities, :zip, :integer
    add_column :cities, :lat, :decimal, :precision => 15, :scale => 6
    add_column :cities, :lng, :decimal, :precision => 15, :scale => 6
  end
end
