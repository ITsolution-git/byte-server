class AddTokenToServer < ActiveRecord::Migration
  def change
    remove_column :servers, :avatar
    add_column :servers, :token, :string
  end
end
