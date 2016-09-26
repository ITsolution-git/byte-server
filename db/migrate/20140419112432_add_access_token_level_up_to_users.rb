class AddAccessTokenLevelUpToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_token_levelup, :string
  end
end
