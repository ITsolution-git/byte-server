class AddChainNameToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :chain_name, :string
  end
end
