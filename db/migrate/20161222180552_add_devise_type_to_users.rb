class AddDeviseTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :devise_token, :string
  end
end
