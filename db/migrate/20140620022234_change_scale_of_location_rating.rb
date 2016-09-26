class ChangeScaleOfLocationRating < ActiveRecord::Migration
  def up
    change_column :locations, :rating, :decimal, :precision => 3, :scale => 1
  end

  def down
  end
end
