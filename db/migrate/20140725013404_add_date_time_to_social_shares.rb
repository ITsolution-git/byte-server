class AddDateTimeToSocialShares < ActiveRecord::Migration
  def change
    add_column :social_shares, :date_time, :string
  end
end
