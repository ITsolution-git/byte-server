class AddComUrlToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :com_url, :string
  end
end
