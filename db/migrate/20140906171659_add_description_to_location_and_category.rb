class AddDescriptionToLocationAndCategory < ActiveRecord::Migration
  def change
    add_column :locations, :description, :text
    add_column :categories, :description, :text
    add_column :categories, :order, :string
  end
end
