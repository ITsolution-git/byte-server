class CreateSocialPoints < ActiveRecord::Migration
  def change
    create_table :social_points do |t|
      t.integer :facebook_point, :default => 0
      t.integer :google_plus_point, :default => 0
      t.integer :twitter_point, :default => 0
      t.integer :instragram_point, :default => 0
      t.integer :ibecon_point, :default => 0
      t.integer :location_id

      t.timestamps
    end
  end
end
