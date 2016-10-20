module Api
  module V2
    class RewardsController < Api::BaseController
      respond_to :json

      def index
        @rewards = @user.user_rewards.includes(:reward).where(is_reedemed: false)
      end

      def redeem
        @reward = @user.user_rewards.find(params[:id])
        if @reward.is_reedemed and !@reward.is_valid?
          render json: { error: "The reward you requested is not available." }, status: 422
        else
          @reward.update_attribute(:is_reedemed, true)
          render json: { success: "The reward is redeemed successfully." }, status: 200
        end
      end
    end
  end
end
