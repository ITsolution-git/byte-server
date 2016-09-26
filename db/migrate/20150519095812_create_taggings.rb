class CreateTaggings < ActiveRecord::Migration
  def up
    create_table :taggings do |t|
      t.integer :taggable_id
      t.string  :taggable_type
      t.integer :tag_id

      t.timestamps null: false
    end

    add_index :taggings, :taggable_id
  end

  def down
    drop_table :taggings
  end
end
