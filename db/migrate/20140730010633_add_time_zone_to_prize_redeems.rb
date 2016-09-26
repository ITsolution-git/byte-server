class AddTimeZoneToPrizeRedeems < ActiveRecord::Migration
  def change
    add_column :prize_redeems, :timezone, :string
  end
end
