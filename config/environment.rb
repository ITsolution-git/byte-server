# Load the rails application
require File.expand_path('../application', __FILE__)

  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.mandrillapp.com',
    :port           => '587',
    :authentication => :plain,
    :user_name      => Figaro.env.mandrill_username,
    :password       => Figaro.env.mandrill_password,
    :domain         => 'mybyteapp.com',
    :enable_starttls_auto => true
  }
# Initialize the rails application
Imenu::Application.initialize!
