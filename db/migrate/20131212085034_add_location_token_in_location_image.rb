class AddLocationTokenInLocationImage < ActiveRecord::Migration
  def change
    add_column :location_images, :location_token, :string
    add_column :location_images, :index, :integer
  end
end
