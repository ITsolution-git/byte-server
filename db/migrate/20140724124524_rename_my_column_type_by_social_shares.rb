class RenameMyColumnTypeBySocialShares < ActiveRecord::Migration
  def up
     rename_column :social_shares, :type, :socai_type
  end

  def down
  end
end
