class PackageFetcher
  include ActionView::Helpers::TextHelper
  attr_reader :packages, :byte_package, :list_enabled

  def initialize(options = {})
    @options = options
    begin
      packages = parse_packages(Braintree::Plan.all)
      @packages = packages.reject {|p| p[:id] == BYTE_PLANS[:byte] }
      @byte_package = packages.select {|p| p[:id] == BYTE_PLANS[:byte] }
    rescue Braintree::ServerError,
           Braintree::SSLCertificateError,
           Braintree::UnexpectedError
      @packages = []
    end
  end

  def list_enabled
    local_package_ids = Admin::Package.enabled.map(&:package_id)
    @packages.select { |package| local_package_ids.include? package[:id] }
  end

  private

  def parse_packages(packages)
    packages.map do |package|
      {
        id: package.id,
        name: package.name,
        time: create_time(package),
        price: price_for(package),
        billing_frequency: freq_for(package),
        active_accounts: active_accounts(package),
        trial_accounts: trial_accounts(package),
        status: status(package)
      }
    end
  end

  def create_time(package)
    package.created_at.strftime('%I:%M %p')
  end

  def price_for(package)
    "#{package.currency_iso_code} #{package.price}"
  end

  def freq_for(package)
    if package.billing_frequency == 1
      'Monthly'
    else
      "Each #{pluralize(package.billing_frequency, 'month')}"
    end
  end

  def package_subscriptions(package)
    subscriptions_ids = Subscription.where(plan_id: package.id).map(&:subscription_id)
    subscriptions_ids.map do |id|
      begin
        Braintree::Subscription.find(id)
      rescue Braintree::ServerError,
             Braintree::SSLCertificateError,
             Braintree::UnexpectedError
      end
    end
  end

  def active_accounts(package)
    return if @options[:no_stats]

    package_subscriptions(package).select do |s|
      s.status == 'Active'
    end.count
  end

  def trial_accounts(package)
    return if @options[:no_stats]

    package_subscriptions(package).select do |s|
      s.status == 'Trial'
    end.count
  end

  def status(package)
    package = Admin::Package.where(package_id: package.id).first
    package.present? && package.enabled?
  end
end
