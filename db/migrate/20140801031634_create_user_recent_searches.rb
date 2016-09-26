class CreateUserRecentSearches < ActiveRecord::Migration
  def change
    create_table :user_recent_searches do |t|
      t.integer :user_id
      t.string :keyword, :limit => 1000
      t.string :search_type, :limit => 11

      t.timestamps
    end
  end
end
