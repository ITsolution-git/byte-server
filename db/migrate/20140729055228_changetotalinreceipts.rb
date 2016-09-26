class Changetotalinreceipts < ActiveRecord::Migration
  def up
    change_column :receipts, :total, :decimal, :precision=> 10, :scale=>5
  end

  def down
  end
end
