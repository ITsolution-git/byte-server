class AddLocationIdToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :location_id, :integer
  end
end
