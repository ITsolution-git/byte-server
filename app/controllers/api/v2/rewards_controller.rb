module Api
  module V2
    class RewardsController < Api::BaseController
      before_filter :set_reward, only: [:redeem_code]
      before_filter :set_user_reward, only: [:scan, :redeem]
      respond_to :json

      def index
        @user_rewards = @user.user_rewards.includes(:reward).where(is_reedemed: false)
      end

      # Redeem Normally
      def redeem
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
        @user_reward = @user.user_rewards.find(params[:user_reward_id])
        if @reward.is_valid? && @reward.redeem_by_qrcode && @user_reward.is_reedemed.eql?(false) && @user_reward.reward_id.eql?(@reward.id)
          @user_reward.update_attribute(:is_reedemed, true)
          @reward.update_attribute :stats, (@reward.stats + 1)
          render json: { success: "The reward is redeemed successfully.", id: @user_reward.id }, status: 200
        else
          render json: { error: "The reward you requested is not available." }, status: 422
        end
      end

      def send_code
        @reward = Reward.where(share_link: params[:code]).first
        if @reward.present?
          if (Time.current > @reward.available_from) and (Time.current < @reward.expired_until)
              UserReward.create(
                reward_id: @reward.id,
                sender_id: @user.id,
                receiver_id: @user.id,
                location_id: @reward.location_id
              )
              render json: { success: "The reward is sent successfully.", data: @reward }, status: 200
          else
              render json: { error: "The prize has expired." }, status: 200
          end
        else
          render json: { error: "Invalid prize code please try again" }, status: 200
        end
      end

      private

      def set_reward
        @reward = Reward.find(params[:id])
      end

      def set_user_reward
        @user_reward = @user.user_rewards.find(params[:id])
      end
    end
  end
end
