class AddPublishedDateToMenu < ActiveRecord::Migration
  def change
    add_column :menus, :published_date, :datetime
  end
end
