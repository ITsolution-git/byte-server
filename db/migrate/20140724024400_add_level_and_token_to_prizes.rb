class AddLevelAndTokenToPrizes < ActiveRecord::Migration
  def change
    add_column :prizes, :level, :integer
    add_column :prizes, :token, :string
  end
end
