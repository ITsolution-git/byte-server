class RewardReport
  include Sidekiq::Worker

  def perform(location_id)
    restaurant = Location.find(location_id)
    rewards = restaurant.rewards
    emails = rewards.map{ |r| r.weekly_reward_email }.join(",").split(",").uniq
    UserMailer.send_email_weekly_prize_report(emails, restaurant, rewards).deliver if emails.present?
  end
end
