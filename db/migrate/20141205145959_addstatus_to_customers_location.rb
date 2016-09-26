class AddstatusToCustomersLocation < ActiveRecord::Migration
  def change
    unless CustomersLocations.column_names.include?("status")
      add_column :customers_locations, :status, :integer
    end  
  end
end
