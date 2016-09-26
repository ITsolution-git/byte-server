module Api
  module V2
    class ItemRatingsController < Api::BaseController
      respond_to :json

      def show
        @location = Location.where(id: params[:rating_id]).first
        @ratings = if @location.present?
          item = @location.items.select {|i| i.id == params[:item_id].to_i }.first
          if item.present?
            lim = params[:limit].present? ? params[:limit].to_i : 20
            result = item.item_comments
              .group_by{ |r| r.created_at.to_date }
              .map{ |_, v| v }
              .reverse
              .flatten
              .take(lim)
              .sort{|x, y| y.updated_at <=> x.updated_at}
            result
          else
            []
          end
        else
          []
        end

        render 'api/v2/ratings/show'
      end

      def index
        @page_num = params[:page_num]
        @location = Location.where(id: params[:rating_id]).first
        @ratings = if @location.present?
           item = @location.items.select {|i| i.id == params[:item_id].to_i }.first
           if item.present?
             lim = params[:limit].present? ? params[:limit].to_i : 20
             result = item.item_comments
                          .group_by{ |r| r.created_at.to_date }
                          .map{ |_, v| v }
                          .reverse
                          .flatten
                          .sort{|x, y| y.updated_at <=> x.updated_at}
             result = Kaminari.paginate_array(result).page(@page_num).per(20);
             result
           else
             []
           end
         else
           []
         end

        render 'api/v2/ratings/index'
      end

      def create
        error = ''
        @location = Location.where(id: params[:rating_id]).first
        if @location.present?
          item = @location.items.select {|i| i.id == params[:item_id].to_i }.first
          if item.present?
            ic = ItemComment.new(user_id: params[:rating][:user_id],
                                 text: params[:rating][:text],
                                 rating: params[:rating][:rating],
                                 checkin_id: params[:rating][:checkin_id],
                                 build_menu_id: params[:rating][:build_menu_id])
            ic.order_item_id = item.id
            if ic.save
              return render json: 200 , json: { status: :ok, error: error }
            else
              error = ic.errors.full_messages
            end
          else
            error = 'Item does not exist'
          end
        else
          error = 'Location does not exist'
        end
        render json: 500 , json: { status: :error, error: error }
      end
    end
  end
end
