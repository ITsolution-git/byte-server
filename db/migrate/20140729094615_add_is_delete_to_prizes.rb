class AddIsDeleteToPrizes < ActiveRecord::Migration
  def change
    add_column :prizes, :is_delete, :integer
  end
end
