class AddRefreshAndAccessTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :gg_access_token, :string
    add_column :users, :gg_refresh_token, :string
  end
end
