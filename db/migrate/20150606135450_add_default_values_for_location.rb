class AddDefaultValuesForLocation < ActiveRecord::Migration
  def up
    change_column :locations, :tax, :float, default: 0

    execute <<-SQL
      UPDATE locations
      SET tax = 0.0
      WHERE locations.tax IS NULL
    SQL
  end

  def down
    change_column :locations, :tax, :float, default: nil
  end
end
