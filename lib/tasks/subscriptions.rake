namespace :subscriptions do

  desc "Refresh Subscription Billing Dates"
  task refresh: :environment do
    subscriptions = Subscription.where("subscription_id IS NOT NULL")
    progress_bar = ProgressBar.create(title: 'Refreshing Subscription Billing Dates', total: subscriptions.count)
    message = "* Starting refresh of Subscription billing dates via rake task"
    puts message
    Rails.logger.warn message
    start_time = Time.now

    # Actual work here
    subscriptions.each do |sub|
      sub.refresh_billing_date
      progress_bar.increment
    end

    message = "[#{DateTime.now}]* Finished refresh of #{subscriptions.count} Subscription billing dates via rake task (#{( Time.now - start_time ).round(1)}s)"
    puts message
    Rails.logger.warn message
  end
end
