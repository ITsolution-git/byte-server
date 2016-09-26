object @location
    attributes :id, :name, :address, :city,:state,:country,:created_at, :lat, :long, :phone,  :url, :rating, :redemption_password, :slug, :state, :subscription_type, :updated_at, :zip, :tax,  :bio,:owner_id, :twiter_url,:facebook_url,:google_url,:instagram_username, :com_url,
    :primary_cuisine, :secondary_cuisine, :fee, :service_fee_type
    node :logo do |loc|
      loc.logo.fullpath if loc.logo.present?
    end
    attribute :check_status_location => :open_now
    node(:hour_of_operation) do |l|
        partial('locations/hour_operation', :object => l.get_hour_operation())
    end

    child @hour_of_operation => "hour_of_operation_v1" do
      node(:day_of_week) {|h| h.day}
      attributes :time_open, :time_close
    end

    node(:isFavourite) do
      if @favourite.present?
        { "favourite" => @favourite.try(:favourite).to_i }
      else
        { "favourite" => 0 }
      end
    end

    child @point => "dinner" do
      attributes :total, :dinner_status
    end

    child :location_image_photos => :images do
      attributes :location_id
      node(:image){|v| v.photo.fullpath if v.photo.present?}
    end
    child @suspend => "user_status" do
      node (:status) {|m| m.is_deleted}
    end
    child @packages => 'location_packages' do
      node(:subscription_id) { |n| n[:id] }
      node(:package_id) { |n| n[:package_id] }
      node(:expiration_date) { |n| n[:due] }
    end
