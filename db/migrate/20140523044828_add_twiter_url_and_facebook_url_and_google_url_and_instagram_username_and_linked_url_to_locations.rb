class AddTwiterUrlAndFacebookUrlAndGoogleUrlAndInstagramUsernameAndLinkedUrlToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :twiter_url, :string
    add_column :locations, :facebook_url, :string
    add_column :locations, :google_url, :string
    add_column :locations, :instagram_username, :string
    add_column :locations, :linked_url, :string
  end
end
