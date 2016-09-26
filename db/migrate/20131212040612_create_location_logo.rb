class CreateLocationLogo < ActiveRecord::Migration
  def change
    remove_column :locations, :logo
    add_column :locations, :token, :string
    create_table :location_logos do |t|
      t.integer :location_id
      t.string :image
      t.string :location_token
      t.timestamps
    end
  end
end
