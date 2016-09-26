class ChangeNumericRatingInItems < ActiveRecord::Migration
  def up
    change_column :items, :rating, :decimal, :precision=> 3, :scale=>1
  end

  def down
  end
end
