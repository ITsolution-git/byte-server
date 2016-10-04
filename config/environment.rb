# Load the rails application
require File.expand_path('../application', __FILE__)

  ActionMailer::Base.smtp_settings = {
    :address        => 'email-smtp.us-east-1.amazonaws.com',
    :port           => 587,
    :authentication => :login,
    :user_name      => 'AKIAIH72T4V6UDZRCK3A',
    :password       => 'AjdEH4BNWD//7CfbsCdLIz3I/FGT0qRIRDvU5Kkv0fp7',
    :domain         => 'mybyteapp.com',
    :enable_starttls_auto => true
  }
# Initialize the rails application
Imenu::Application.initialize!
