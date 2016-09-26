class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.string :date
      t.string :store
      t.integer :ticket
      t.float :total

      t.timestamps
    end
  end
end
