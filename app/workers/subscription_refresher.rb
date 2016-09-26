class SubscriptionRefresher
  include Resque::Plugins::Status
  include Resque::Plugins::UniqueJob
  @queue = :subscriptions

  def self.perform(subscription_id, action)
    begin
      subscription = Subscription.find(subscription_id)
    rescue ActiveRecord::RecordNotFound
      Rails.logger.error "* SubscriptionRefresher could not find Subscription[#{subscription_id}] for action #{action}"
      return
    end

    case action
    when "refresh_billing_date"
      refresh_billing_date(subscription)
    else
      Rails.logger.error "* SubscriptionRefresher could not identify action '#{action}' for Subscription[#{subscription_id}]"
      return
    end
  end

  def self.refresh_billing_date(subscription)
    subscription.refresh_billing_date
  end
end
