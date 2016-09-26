class AddRepeatTimeToMenu < ActiveRecord::Migration
  def change
    add_column :menus, :repeat_time, :string
  end
end
