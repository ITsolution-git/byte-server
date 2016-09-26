class SubscriptionCreator
  attr_reader :subscription

  def initialize(options)
    @subscription = create(options)
  end

  private

  def create(options)
    member = fetch_member(options[:member_id])
    return false if member.nil?

    payment_method = member.payment_methods.detect { |pm| pm.default }
    return false if payment_method.nil?

    @result =
      begin
        Braintree::Subscription.create(
          payment_method_token: payment_method.token,
          plan_id: options[:plan_id]
        )

      rescue Braintree::ServerError,
           Braintree::SSLCertificateError,
           Braintree::UnexpectedError
        return
      end
  end

  def fetch_member(id)
    return if id.nil?

    begin
      Braintree::Customer.find(id)
    rescue Braintree::ServerError,
           Braintree::SSLCertificateError,
           Braintree::UnexpectedError
      return
    end
  end
end
