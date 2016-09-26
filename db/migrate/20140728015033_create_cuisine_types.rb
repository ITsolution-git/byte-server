class CreateCuisineTypes < ActiveRecord::Migration
  def change
    create_table :cuisine_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
