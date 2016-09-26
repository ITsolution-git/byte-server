module Api
      module V2
        class LocationSerializer < ActiveModel::Serializer
      attributes :id, :name, :address, :city, :state, :phone, :url, :rating, :rating_total, :zip,
        :tax, :bio, :logo, :twitter_url, :facebook_url, :google_url, :instagram_username, :favourited,
        :is_checked_in, :favourited_total, :open_now, :photos, :lat, :long, :cuisine_types, :hours_of_operation, :contests,
        :packages, :favorited_date

      def photos
        object.images.map do |image|
          {
              url: image.url
          }
        end
      end

      def hours_of_operation
        object.hour_operations.map do |hour_operation|
          {
              day_of_week: hour_operation.day,
              time_close: hour_operation.time_close,
              time_open: hour_operation.time_open
          }
        end
      end

      # def unread_messages
      #   @restaurant = Location.get_global_message(scope.email, object.id).first
      #   @restaurant.present? ? @restaurant.unread : 0
      # end
      #
      # def unlocked_prizes
      #   @points = object.points_awarded_for_checkin + scope.points
      #   @prizes = Prize.get_unlocked_prizes_by_location(object.id, @points, scope.id)
      #   @prizes.count
      # end

      def contests
        @contests = Contest.all
        @res_contests = []
        @contests.each do |c|
          if Time.parse(c.start_date) < Time.now && Time.parse(c.end_date) > Time.now
            @restaurants = c.restaurants.split(",").map { |s| s.to_i }
            if @restaurants.include?(object.id)
              @res_contests.push(c)
            end
          end
        end
        @res_contests
      end

      def logo
        object.logo.try(:url)
      end

      def rating_total
        object.grades.count
      end

      def twitter_url
        object.twiter_url
      end

      def favourited
        favorites = object.location_favourites.where(user_id: scope.id)
        favorites.present? && favorites.any?{|favorite| favorite.favourite == 1}
      end

      def favourited_total
        object.location_favourites.where(favourite: 1).count
      end

      def is_checked_in
        checked_in = object.location_visiteds.where(user_id: scope.id)
        checked_in.present? && checked_in.any?{|check_in| check_in.visited == 1}
      end

      def open_now
        object.check_status_location
      end

      def cuisine_types
        res = []
        res << {name: object.primary_cuisine} if object.primary_cuisine.present?
        res << {name: object.secondary_cuisine} if object.secondary_cuisine.present?
        res
      end

      def packages
        object.subscriptions.map do |package|
          {
              subscription_id: package.subscription_id.to_s,
              plan_id: package.plan_id.to_s

          }
        end
      end

      def favorited_date
        favorite = object.location_favourites.where(user_id: scope.id).first

        if favorite.present?
          favorite.updated_at
        end
      end
    end
  end
end
