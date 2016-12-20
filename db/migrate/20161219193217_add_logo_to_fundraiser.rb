class AddLogoToFundraiser < ActiveRecord::Migration
  def change
    add_column :fundraisers, :logo, :string
  end
end
