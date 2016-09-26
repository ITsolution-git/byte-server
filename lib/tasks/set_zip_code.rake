namespace :user do

  desc "Set zip code"
  task :set_zip_code, [:filename] => :environment do |t, args|
    users = User.all
    unless users.blank?
      users.each do |user|
        zip = user.zip
        unless zip.blank?
          gr = Geocoder.search(zip) 
          puts gr[0]
          if !gr[0].blank? && !gr[0].nil?
            location = gr[0].data["geometry"]["location"]
            user.latitude = location["lat"]
            user.longitude = location["lng"]
            user.save(:validate=>false)
          end  
        end  
      end
    end
  end
end
