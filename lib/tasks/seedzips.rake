task :seedzips => :environment do 
  require 'csv'

  CSV.foreach("ZipCodeDB.csv", :headers => true) do |row|
    Zipcode.create!(row.to_hash)
  end
end