class ChangeNexttimeToInteger < ActiveRecord::Migration
  def up
  	change_column :item_nexttimes, :nexttime, :integer
  end
  def down
  end
end
