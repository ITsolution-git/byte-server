class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :package_id
      t.boolean :enabled

      t.timestamps
    end
  end
end
