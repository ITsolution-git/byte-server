class AddPhysicalAddressAndPhysicalCityAndPhysicalCountryAndPhysicalZipToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :physical_address, :string
    add_column :profiles, :physical_city, :string
    add_column :profiles, :physical_country, :string
    add_column :profiles, :physical_zip, :string
  end
end
