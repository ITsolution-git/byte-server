class RenameColumnTimClose < ActiveRecord::Migration
  def up
  	rename_column :hour_operations, :tim_close, :time_close
  end

  def down
  end
end
