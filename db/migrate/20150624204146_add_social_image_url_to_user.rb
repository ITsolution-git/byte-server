class AddSocialImageUrlToUser < ActiveRecord::Migration
  def change
    add_column :users, :social_image_url, :string
  end
end
