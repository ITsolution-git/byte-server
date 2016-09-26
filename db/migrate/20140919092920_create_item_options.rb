class CreateItemOptions < ActiveRecord::Migration
  def change
    if !ActiveRecord::Base.connection.table_exists? 'item_options'
      create_table :item_options do |t|
        t.string :name
        t.integer :only_select_one, :default => 0

        t.timestamps
      end
    end
  end
end
