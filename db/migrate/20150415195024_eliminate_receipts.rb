class EliminateReceipts < ActiveRecord::Migration
  def up
    drop_table :receipts

    remove_column :item_comments, :image # This was apparently the receipt image
  end

  def down
    create_table "receipts" do |t|
      t.string   "date"
      t.string   "store"
      t.integer  "ticket"
      t.decimal  "total", :precision => 10, :scale => 5
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.integer  "notifications_id"
    end

    add_column :item_comments, :image, :string
  end
end
