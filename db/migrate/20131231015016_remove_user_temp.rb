class RemoveUserTemp < ActiveRecord::Migration
  def change
    drop_table :user_temps
  end
end
