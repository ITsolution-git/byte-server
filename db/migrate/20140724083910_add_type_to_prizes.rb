class AddTypeToPrizes < ActiveRecord::Migration
  def change
    add_column :prizes, :type, :string
  end
end
