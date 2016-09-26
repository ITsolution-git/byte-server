class AddTextToServerRating < ActiveRecord::Migration
  def change
    add_column :server_ratings, :text, :text
  end
end
