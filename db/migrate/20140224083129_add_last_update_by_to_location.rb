class AddLastUpdateByToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :last_updated_by, :integer
  end
end
