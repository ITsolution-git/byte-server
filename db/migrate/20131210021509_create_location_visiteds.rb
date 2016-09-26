class CreateLocationVisiteds < ActiveRecord::Migration
  def change
    create_table :location_visiteds do |t|
      t.integer :location_id
      t.integer :user_id
      t.integer :visited, :default=>0

      t.timestamps
    end
  end
end
