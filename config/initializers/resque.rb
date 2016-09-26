require 'resque/status_server'

if Rails.env.production?
  Resque.redis = '10.132.229.58'
elsif Rails.env.staging?
  Resque.redis = '10.132.206.181'
else
  Resque.redis = 'localhost:6379'
end
Resque::Plugins::Status::Hash.expire_in = (24 * 60 * 60) # 24hrs in seconds
