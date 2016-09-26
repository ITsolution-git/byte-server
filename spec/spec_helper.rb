require 'simplecov'

if ENV['COVERAGE']
  SimpleCov.start do
    nocov_token 'skippit'
  end
end

RSpec.configure do |config|
  config.order = :random
  config.mock_with :rspec

  config.after(:each) do
    if Rails.env.test? || Rails.env.cucumber?
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
    end
  end
end
