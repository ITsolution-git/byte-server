require 'resque/tasks'

task 'resque:setup' => :environment do
  ENV['QUEUE'] = '*'
end

# Add logging, and limit to 1 file of 2MB
Resque.logger = Logger.new("#{Rails.root}/log/resque.log", 1, 2.megabytes)
