# Load the rails application
require File.expand_path('../application', __FILE__)

  ActionMailer::Base.smtp_settings = {
    :address        => 'email-smtp.us-east-1.amazonaws.com',
    :port           => 587,
    :authentication => :login,
    :user_name      => Figaro.env.ses_username,
    :password       => Figaro.env.ses_password,
    :domain         => 'mybyteapp.com',
    :enable_starttls_auto => true
  }
# Initialize the rails application
Imenu::Application.initialize!
