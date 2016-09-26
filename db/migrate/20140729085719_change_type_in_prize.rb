class ChangeTypeInPrize < ActiveRecord::Migration
  def up
    rename_column :prizes, :type, :role
  end

  def down
  end
end
