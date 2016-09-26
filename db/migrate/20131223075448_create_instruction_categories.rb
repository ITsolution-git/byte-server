class CreateInstructionCategories < ActiveRecord::Migration
  def change
    create_table :instruction_categories do |t|
      t.string :name
      t.string :icon

      t.timestamps
    end
  end
end
