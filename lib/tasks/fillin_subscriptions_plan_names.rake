namespace :subscriptions do
  desc "Fetch plan names from the Braintree"
    task :fill_in_plan_names => :environment do |t, args|
    puts 'Task started'
      begin
        packages = PackageFetcher.new.packages

        Subscription.all.each do |subscription|
          res = Braintree::Subscription.find subscription.subscription_id
          plan = packages.detect { |p| p[:id] == res.plan_id }
          if plan.present?
            subscription.update_attribute(:plan_name, plan[:name])
          else
            subscription.update_attribute(:plan_name, 'No plan')
          end
        end
      rescue Braintree::AuthenticationError,
             Braintree::AuthorizationError,
             Braintree::ConfigurationError,
             Braintree::DownForMaintenanceError,
             Braintree::ForgedQueryString,
             Braintree::InvalidSignature,
             Braintree::NotFoundError,
             Braintree::ServerError,
             Braintree::SSLCertificateError,
             Braintree::UnexpectedError,
             Braintree::UpgradeRequiredError,
             Braintree::ValidationsFailed,
             Braintree::ServerError,
             Braintree::SSLCertificateError,
             Braintree::UnexpectedError
        'No plan'
      end
    puts 'Task finished'
  end

  task :fill_in_byte_accs => :environment do |t, args|
    puts 'Task started'
    result =
      begin
        Braintree::Subscription.search { |search| search.plan_id.is BYTE_PLANS[:byte] }
      rescue Braintree::AuthenticationError,
         Braintree::AuthorizationError,
         Braintree::ConfigurationError,
         Braintree::DownForMaintenanceError,
         Braintree::ForgedQueryString,
         Braintree::InvalidSignature,
         Braintree::NotFoundError,
         Braintree::ServerError,
         Braintree::SSLCertificateError,
         Braintree::UnexpectedError,
         Braintree::UpgradeRequiredError,
         Braintree::ValidationsFailed,
         Braintree::ServerError,
         Braintree::SSLCertificateError,
         Braintree::UnexpectedError
      end
      status_customer_ids = result.map { |t| { id: t.transactions.first.customer_details.id, status: t.status } }
      progress_bar = ProgressBar.create(title: 'Users', total: User.count)
      User.all.each do |user|
        has_byte = status_customer_ids.detect { |s| s[:status] != 'Canceled' && s[:id] == user.customer_id }
        if has_byte.present?
          puts "Updating user with id: #{user.id}"
          user.update_attribute(:has_byte, true)
        end
        progress_bar.increment
      end
      puts 'Task finished'
  end
end
