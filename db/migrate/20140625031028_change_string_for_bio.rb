class ChangeStringForBio < ActiveRecord::Migration
  def up
    change_column :locations, :bio, :string, :limit => 10000
  end

  def down
  end
end
