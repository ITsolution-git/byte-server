class AddDefaultValueToIsDeleteInPrizes < ActiveRecord::Migration
  def change
    change_column :prizes, :is_delete, :integer, :default => 0
  end
end
