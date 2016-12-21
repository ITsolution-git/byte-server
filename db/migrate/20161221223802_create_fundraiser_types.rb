class CreateFundraiserTypes < ActiveRecord::Migration
  def change
    create_table :fundraiser_types do |t|
      t.integer :fundraiser_id
      t.string :name
      t.string :image

      t.timestamps
    end
  end
end
