class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :location

  validates :user, presence: true
  validates :location, presence: true
  validates :plan_id, presence: true

  attr_accessible :plan_name, :plan_id, :location_id

  # Lookup next billing date from Braintree
  def refresh_billing_date
    new_next_billing_date = nil
    begin
      bt_sub = Braintree::Subscription.find(self.subscription_id)
      new_next_billing_date = bt_sub.next_billing_date
    rescue Braintree::ServerError,
      Braintree::SSLCertificateError,
      Braintree::UnexpectedError,
      Braintree::NotFoundError => e
      logger.warn "#{__FILE__}:#{__LINE__} Error fetching new Subscription billing date from Braintree.
        Won't update next_billing_date. : #{e}"
    end
    if new_next_billing_date.present?
      parsed_date = DateTime.parse(new_next_billing_date)
      self.next_billing_date = new_next_billing_date
      self.billing_active = self.next_billing_date.present? && self.next_billing_date > DateTime.now
    else
      return false
    end
  end

  # Refresh expiration date via Background Worker
  def async_refresh_billing_date
    Resque.enqueue(SubscriptionRefresher, self.id, "refresh_billing_date")
  end

end
