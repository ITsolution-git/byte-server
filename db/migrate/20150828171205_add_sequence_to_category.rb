class AddSequenceToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :sequence, :integer
  end
end
