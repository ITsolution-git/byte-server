class AddColumnToServerAvatar < ActiveRecord::Migration
  def change
    add_column :server_avatars, :image_crop, :string
  end
end
