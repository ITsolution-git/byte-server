class AddStatusIdToPrizes < ActiveRecord::Migration
  def change
    add_column :prizes, :status_id, :integer
  end
end
