class AddAvatarReceiptToItemComments < ActiveRecord::Migration
  def change
    add_column :item_comments, :avatar_receipt, :string
  end
end
