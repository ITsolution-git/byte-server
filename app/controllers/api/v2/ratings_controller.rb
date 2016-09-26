module Api
  module V2
    class RatingsController < Api::BaseController
      respond_to :json

      def show
        @location = Location.where(id: params[:id]).first
        @ratings = @location.present? ? location_ratings : []
      end

      def index
        @page_num = params[:page_num].present? ? params[:page_num] : 1
        lim = params[:limit].present? ? params[:limit].to_i : 20
        @location = Location.where(id: params[:location_id]).first
        @results = @location.items.map { |item| item.item_comments }
                       .flatten
                       .compact
                       .group_by{ |r| r.created_at.to_date }
                       .map{ |_, v| v }
                       .reverse
                       .flatten
                       .sort{|x, y| y.updated_at <=> x.updated_at}
        @ratings = Kaminari.paginate_array(@results).page(@page_num).per(20);
        render 'api/v2/ratings/comment'
      end

      private

      def location_ratings
        lim = params[:length].present? ? params[:length].to_i : 20
        @ratings = @location.items.map { |item| item.item_comments }
          .flatten
          .compact
          .group_by{ |r| r.created_at.to_date }
          .map{ |_, v| v }
          .reverse
          .flatten
          .take(lim)
      end
    end
  end
end
