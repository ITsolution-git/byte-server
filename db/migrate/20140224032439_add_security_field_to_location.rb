class AddSecurityFieldToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :rsr_admin, :string
    add_column :locations, :rsr_manager, :string
    add_column :locations, :created_by, :integer
  end
end
