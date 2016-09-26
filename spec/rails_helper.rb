ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'
SimpleCov.start unless ENV['NO_COVERAGE'] # You can skip SimpleCov with "NO_COVERAGE=true bundle exec rspec"
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
require 'devise'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/poltergeist'

WebMock.disable_net_connect!(allow_localhost: true, :allow => ['maps.googleapis.com', 'api.braintreegateway.com', 'api.sandbox.braintreegateway.com'])

# Include all custome stuff from the support dir
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  Capybara.default_driver         = :rack_test
  Capybara.javascript_driver      = :poltergeist
  Capybara.ignore_hidden_elements = false
  Capybara.default_wait_time      = 5

  # To use non-headless driver, uncomment beneath and comment :webkit driver option
  #
  # Capybara.register_driver :chrome do |app|
  # Capybara::Selenium::Driver.new(app, browser: :chrome)
  # end
  # Capybara.javascript_driver = :chrome

  config.infer_spec_type_from_file_location!

  # factory methods
  config.include FactoryGirl::Syntax::Methods

  # helper methods
  config.extend Features::ControllerMacros, type: :controller
  config.include Devise::TestHelpers, type: :controller
  config.include Features::BuildMenuHelper
  config.include Features::SessionHelpers, type: :feature

  # Mocking Geocoder calls
  config.include Lib::MockGeocoder

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.before(:each) do
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear

    # Stub all external requests
    stub_request(:get, "http://nominatim.openstreetmap.org/search?accept-language=en&addressdetails=1&format=json&q=12345").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'RKL LLC'}).
      to_return(:status => 200, :body => "", :headers => {})
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
