class AddEtagToUser < ActiveRecord::Migration
  def change
    add_column :users, :etag, :string
  end
end
