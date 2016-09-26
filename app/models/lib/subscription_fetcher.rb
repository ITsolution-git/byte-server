class SubscriptionFetcher
  attr_reader :subscriptions

  def initialize(subscriptions, options = {})
    @subscriptions = fetch(subscriptions)
  end

  private

  def fetch(ids)
    ids.map do |id|
      begin
        parse_subscription(Braintree::Subscription.find(id))
      rescue Braintree::ServerError,
             Braintree::SSLCertificateError,
             Braintree::UnexpectedError
      end
    end
  end

  def parse_subscription(subscription)
      {
        id: subscription.id,
        package_id: subscription.plan_id,
        due: get_due(subscription),
        status: get_status(subscription),
        plan: get_plan(subscription)
      }

  end

  def get_due(subscription)
    subscription.billing_period_end_date
  end

  def get_status(subscription)
    subscription.status
  end

  def get_plan(subscription)
    subscription = Subscription.where(subscription_id: subscription.id).first
    subscription.present? ? subscription.plan_name : 'no plane name'
  end
end
