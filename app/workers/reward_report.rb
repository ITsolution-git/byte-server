class RewardReport
  include Sidekiq::Worker
  sidekiq_options retry: false


  def perform(reward_id)
    reward = Reward.find(reward_id)
    UserMailer.send_email_weekly_prize_report(reward).deliver if reward.weekly_reward_email.present?
  end
end
