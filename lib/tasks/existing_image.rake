namespace :upload do

  desc "import existing local image to AWS"
  task :existing_image, [:filename] => :environment do |t, args|
    
    puts "LocationLogo"
    location_logos = LocationLogo.all
    unless location_logos.blank?
      location_logos.each do |location_logo|
        puts location_logo.save(:validate=>false)
      end
    end  
    
    puts "InfoAvatar"
    info_avatars = InfoAvatar.all
    unless info_avatars.blank?
      info_avatars.each do |info_avatar|
        puts info_avatar.save(:validate=>false)
      end
    end  
    
    puts "LocationImage"
    location_images = LocationImage.all
    unless location_images.blank?
      location_images.each do |location_image|
        puts location_image.save(:validate=>false)
      end
    end  
    
    puts "ItemImage"
    item_images = ItemImage.all
    unless item_images.blank?
      item_images.each do |item_image|
        puts item_image.save(:validate=>false)
      end
    end 
    
    puts "ServerAvatar"
    server_avatars = ServerAvatar.all
    unless server_avatars.blank?
      server_avatars.each do |server_avatar|
        puts server_avatar.save(:validate=>false)
      end
    end
    
    puts "UserAvatar"
    user_avatars = UserAvatar.all
    unless user_avatars.blank?
      user_avatars.each do |user_avatar|
        puts user_avatar.save(:validate=>false)
      end
    end
    
    puts "User"
    users = User.all
    unless users.blank?
      users.each do |user|
        puts user.save(:validate=>false)
      end
    end
    
    puts "ItemKeyImage"
    item_key_images = ItemKeyImage.all
    unless item_key_images.blank?
      item_key_images.each do |item_key_image|
        puts item_key_image.save(:validate=>false)
      end
    end
    
    puts "Item"
    items = Item.all
    unless items.blank?
      items.each do |item|
        puts item.save(:validate=>false) unless item.blank?
      end
    end
    
    puts "Location"
    locations = Location.all
    unless locations.blank?
      locations.each do |location|
        puts location.save(:validate=>false)
      end
    end
    
    puts "Server"
    servers = Server.all
    unless servers.blank?
      servers.each do |server|
        puts server.save(:validate=>false)
      end
    end
    
    puts "ItemComment"
    item_comments = ItemComment.all
    unless item_comments.blank?
      item_comments.each do |item_comment|
        puts item_comment.save(:validate=>false)
      end
    end
    
  end
end
