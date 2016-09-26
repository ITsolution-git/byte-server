class AddYelpIdToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :yelp_id, :integer
  end
end
