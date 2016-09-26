module Api
  module V2
    class PrizesController < Api::BaseController
      respond_to :json

      def index
        @prizes = nearby_locations.map do |l|
          points = l.points_awarded_for_checkin + @user.points
          prizes = Prize.get_unlocked_prizes_by_location(l.id, points, @user.id)
          prizes.each do |p|
            p.location_id = l.id
            p.location_logo = l.logo.try(:url)
            p.location_cuisine = []
            p.location_cuisine << {name: l.primary_cuisine} if l.primary_cuisine.present?
            p.location_cuisine << {name: l.secondary_cuisine} if l.secondary_cuisine.present?
            p.location_name = l.name
            p.location_lat = l.lat.to_f
            p.location_long = l.long.to_f
            p.byte_prize_type = get_prize_type(p.id)
          end
        end.flatten.compact.uniq{|prize| [prize.id, prize.location_id]}
      end

      private

      def get_prize_type(prize_id)
        share_prize = SharePrize.where(prize_id: prize_id).first
        return share_prize.from_share if share_prize.present?

        user_prize = UserPrize.where(prize_id: prize_id).first
        return 'owner' if user_prize.present?

        return 'immediate'
      end
    end
  end
end
