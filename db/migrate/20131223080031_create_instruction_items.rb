class CreateInstructionItems < ActiveRecord::Migration
  def change
    create_table :instruction_items do |t|
      t.integer :instruction_category_id
      t.string :item_name
      t.string :youtube_id
      t.string :times

      t.timestamps
    end
  end
end
