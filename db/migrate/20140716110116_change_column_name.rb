class ChangeColumnName < ActiveRecord::Migration
  def up
    rename_column :item_comments, :avatar_receipt, :image
  end

  def down
  end
end
