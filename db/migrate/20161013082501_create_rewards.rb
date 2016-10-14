class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.string :name
      t.string :photo
      t.string :share_link
      t.datetime :available_from
      t.datetime :expired_until
      t.string :timezone
      t.text :description
      t.integer :quantity
      t.integer :stats
      t.references :location

      t.timestamps
    end
    add_index :rewards, :location_id
  end
end
