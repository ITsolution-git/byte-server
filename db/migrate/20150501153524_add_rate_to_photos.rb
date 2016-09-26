class AddRateToPhotos < ActiveRecord::Migration
  def up
    add_column :photos, :rate, :integer, default: 1 unless column_exists? :photos, :rate
  end

  def down
    remove_column :photos, :rate if column_exists? :photos, :rate
  end
end
