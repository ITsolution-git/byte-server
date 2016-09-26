class AddLogoUrlToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :logo_url, :string
  end
end
