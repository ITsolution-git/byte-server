class AddRepeatTimeToToMenu < ActiveRecord::Migration
  def change
    add_column :menus, :repeat_time_to, :string
  end
end
