module Api
  module V2
    class RewardsController < Api::BaseController
      before_filter :set_reward, only: [:scan, :redeem_code]
      respond_to :json

      def index
        @user_rewards = @user.user_rewards.includes(:reward).where(is_reedemed: false)
      end

      # Redeem Normally
      def redeem
        @user_reward = @user.user_rewards.find(params[:id])
        if @user_reward.is_reedemed and !@user_reward.reward.is_valid?
          render json: { error: "The reward you requested is not available." }, status: 422
        else
          @user_reward.update_attribute(:is_reedemed, true)
          @user_reward.reward.update_attribute :stats, (@user_reward.reward.stats + 1)
          render json: { success: "The reward is redeemed successfully." }, status: 200
        end
      end

      def scan
      end

      def redeem_code
        if @reward.is_valid? and @reward.redeem_by_qrcode
          @reward.update_attribute :stats, (@reward.stats + 1)
          render json: { success: "The reward is redeemed successfully." }, status: 200
        else
          render json: { error: "The reward you requested is expired or redeem limit exceeded." }, status: 422
        end
      end

      private

      def set_reward
        @reward = Reward.find(params[:id])
      end
    end
  end
end
