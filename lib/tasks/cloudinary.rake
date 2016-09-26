namespace :cloudinary do
  desc 'run restaurant and user image migrations'
  task migrate_images: :environment do
    Rake::Task['cloudinary:migrate_restaurant_images'].invoke
    Rake::Task['cloudinary:migrate_user_avatars'].invoke
    Rake::Task['cloudinary:migrate_info_avatars'].invoke
  end

  desc 'migrate s3 images to cloudinary for restaurants'
  task migrate_restaurant_images: :environment do
    Location.find_each do |location|
      puts "Location #{location.name} (#{location.id})"
      puts "Location Logo"
      if location.location_logo.present? && location.location_logo.image.url.present?
        photo = process_image(location.location_logo, location)
        if photo.present? && location.logo_id != photo.id
          location.update_attribute(:logo_id, photo.id)
        end
      else
        puts "Image Not Present"
      end

      puts "Location Images"
      location.location_images.each do |location_image|
        if location_image.image.url.present?
          photo = process_image(location_image, location)
          if photo.present?
            image = location.location_image_photos.where(index: location_image.index).first
            image ||= location.location_image_photos.create(index: location_image.index)
            image.update_attribute(:photo_id, photo.id) if image.present? && image.photo_id != photo.id
          end
        else
          puts "Image Not Present"
        end
      end

      puts "Server Avatars"
      location.servers.each do |server|
        if server.server_avatar.present? && server.server_avatar.image.url.present?
          photo = process_image(server.server_avatar, location)
          if photo.present? && server.avatar_id != photo.id
            server.update_attribute(:avatar_id, photo.id)
          end
        else
          puts "Image Not Present"
        end
      end

      puts "Item Key Images"
      location.item_keys.each do |item_key|
        if item_key.item_key_image.present? && item_key.item_key_image.image.url.present?
          photo = process_image(item_key.item_key_image, location)
          if photo.present? && item_key.image_id != photo.id
            item_key.update_attribute(:image_id, photo.id)
          end
        else
          puts "Image Not Present"
        end
      end

      puts "Item Images"
      location.items.each do |location_item|
        location_item.item_images.each do |item_image|
          if item_image.image.url.present?
            photo = process_image(item_image, location)
            if photo.present?
              image = location_item.item_photos.first
              image ||= location_item.item_photos.build
              if image.photo_id != photo.id
                image.photo_id = photo.id
                image.save
              end
            end
          else
            puts "Image Not Present"
          end
        end
      end
    end
  end

  desc 'migrate s3 images to cloudinary for Users'
  task migrate_user_avatars: :environment do
    User.all.each do |user|
      puts "User #{user.name} (#{user.id})"
      puts "User Avatar"
      if user.user_avatar.present? && user.user_avatar.image.url.present?
        photo_hash = upload_user_avatar(user)
        if photo_hash.present?
          create_or_update_avatar(user, photo_hash)
        end
      else
        puts "User Avatar Not Preset"
      end
    end
  end

  desc 'migrate s3 images to cloudinary for Infos'
  task migrate_info_avatars: :environment do
    Info.all.each do |info|
      puts "Info #{info.name} (#{info.id})"
      puts "Info Avatar"
      if info.info_avatar.present? && info.info_avatar.image.url.present?
        photo_hash = upload_info_avatar(info)
        if photo_hash.present?
          create_or_update_avatar(info, photo_hash)
        end
      else
        puts "Info Avatar Not Preset"
      end
    end
  end

  def process_image(image_type, location)
    photo_hash = upload_location_image(image_type.image.url, location)
    create_photo(photo_hash, location)
  end

  def upload_location_image(image, location)
    begin
      Cloudinary::Uploader.upload(image, folder: "owners/#{location.owner_id}/locations/#{location.id}",
        public_id: image.split("/").last.split(".").first, overwrite: false)
    rescue => e
      puts "An error has occurred: #{e}"
    end
  end

  def upload_user_avatar(user)
    begin
      Cloudinary::Uploader.upload(user.user_avatar.image.url, folder: "users/#{user.id}",
        public_id: "user_#{user.id}_avatar", overwrite: true)
    rescue => e
      puts "An error has occurred: #{e}"
    end
  end

  def upload_info_avatar(info)
    begin
      Cloudinary::Uploader.upload(info.info_avatar.image.url, folder: "infos/#{info.id}",
        public_id: "info_#{info.id}_avatar", overwrite: true)
    rescue => e
      puts "An error has occurred: #{e}"
    end
  end

  def create_photo(photo_hash, location)
    if photo_hash.present?
      find_or_create_photo_from(photo_hash, location)
    else
      nil
    end
  end

  def find_or_create_photo_from(photo_hash, location)
    if location.photos.include?(Photo.where(public_id: photo_hash["public_id"]).try(:first))
      photo = Photo.where(public_id: photo_hash["public_id"]).first
    else
      photo = location.photos.create(
        public_id: photo_hash["public_id"],
        format: photo_hash["format"],
        version: photo_hash["version"],
        width: photo_hash["width"],
        height: photo_hash["height"],
        resource_type: photo_hash["resource_type"],
        name: photo_hash["name"]
      )
    end
    photo
  end

  def create_or_update_avatar(object, photo_hash)
    photo_attributes = {
      public_id: photo_hash["public_id"],
      format: photo_hash["format"],
      version: photo_hash["version"],
      width: photo_hash["width"],
      height: photo_hash["height"],
      resource_type: photo_hash["resource_type"]
    }
    if object.avatar.present?
      object.avatar.update_attributes(photo_attributes)
    else
      object.create_avatar(photo_attributes)
    end
  end
end
