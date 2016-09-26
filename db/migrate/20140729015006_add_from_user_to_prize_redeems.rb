class AddFromUserToPrizeRedeems < ActiveRecord::Migration
  def change
    add_column :prize_redeems, :from_user, :integer
  end
end
