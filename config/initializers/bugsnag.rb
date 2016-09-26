Bugsnag.configure do |config|
  config.api_key = 'e19c64acabbba4e1ceaad7f45ea3e9f8'
  config.notify_release_stages = %w(production staging staging_bugs)
  config.app_version = '09-23-release-155'
end
