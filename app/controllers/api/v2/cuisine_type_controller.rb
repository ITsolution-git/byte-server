module Api
  module V2
    class CuisineTypeController < Api::BaseController
      skip_before_filter :authenticate_user

      def show
        render json: CuisineType.all.uniq.sort{|x, y| x.name <=> y.name }.collect{|x| x.name}
      end

    end
  end
end
