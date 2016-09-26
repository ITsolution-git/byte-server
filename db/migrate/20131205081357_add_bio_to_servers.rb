class AddBioToServers < ActiveRecord::Migration
  def change
    add_column :servers, :bio, :text
  end
end
