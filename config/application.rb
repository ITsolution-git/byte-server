require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Imenu
  class Application < Rails::Application
    ActiveModel::ArraySerializer.root = false
    ## i18n validation enabled for all languages
    config.i18n.enforce_available_locales = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.assets.initialize_on_precompile = false
    # config.fcm_public_key = "AIzaSyAmlgN1vxj6LIR9Y18uKIfKPZfZeXh2lb8"
    config.fcm_public_key = "AAAAXvtplVs:APA91bEFWEgrogsFZU5OhQZivSieK7QLf3ErPCGv-6pwTgwI54OPmUDkvnEPVLy5ud_Sz7fqTLrczTQSbZjjgpVbVn4pfBpfAN6zeTMO2Qe7NT9RQ26yL1z1uIJJ3jhF1EmFm7Go0Xc27fLYJVsVLQr8ILBMHXHRhg"
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += %W(
      #{config.root}/app/controllers/concerns
      #{config.root}/app/models/concerns
      #{config.root}/app/models/lib
    )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints || database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.precompile = ['*.js', '*.css', '*.png', '*jpg', '*.woff', '*.tff', '*.eot', '*.svg', '*.ico']
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    # Configure time zone
    # config.time_zone = 'Eastern Time (US & Canada)'
    # config.active_record.default_timezone = 'Eastern Time (US & Canada)'

    # Auto rotate log files to prevent log files from getting too large (keep 10 of 10MB each), per:
    # http://www.dzone.com/snippets/how-rotate-your-rails-logs
    config.logger = Logger.new("#{config.root}/log/#{Rails.env}.log", 10, 10.megabytes)

    # Load configuration variables from YAML file
    yaml_file_path = File.expand_path('../config.yml', __FILE__)
    if File.exists?(yaml_file_path)
      yaml_config = YAML.load( File.read(yaml_file_path) )
      env_config = yaml_config.fetch(Rails.env, {})
      yaml_config.merge! env_config if env_config.present?
      yaml_config.each do |key, value|
        ENV[key] ||= value.to_s unless value.kind_of? Hash
      end
    end

  end
end

# require File.expand_path('../boot', __FILE__)

# require 'rails/all'


# if defined?(Bundler)
#   # If you precompile assets before deploying to production, use this line
#   Bundler.require(*Rails.groups(:assets => %w(development test)))
#   # If you want your assets lazily compiled in production, use this line
#   # Bundler.require(:default, :assets, Rails.env)
# end

# module Imenu
#   class Application < Rails::Application
#     # Settings in config/environments/* take precedence over those specified here.
#     # Application configuration should go into files in config/initializers
#     # -- all .rb files in that directory are automatically loaded.

#     # Custom directories with classes and modules you want to be autoloadable.
#     # config.autoload_paths += %W(#{config.root}/extras)

#     # Only load the plugins named here, in the order given (default is alphabetical).
#     # :all can be used as a placeholder for all plugins not explicitly named.
#     # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

#     # Activate observers that should always be running.
#     # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

#     # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
#     # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
#     # config.time_zone = 'Central Time (US & Canada)'

#     # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
#     # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
#     # config.i18n.default_locale = :de

#     # Configure the default encoding used in templates for Ruby 1.9.
#     config.encoding = "utf-8"

#     # Configure sensitive parameters which will be filtered from the log file.
#     config.filter_parameters += [:password]

#     # Enable escaping HTML in JSON.
#     config.active_support.escape_html_entities_in_json = true

#     # Use SQL instead of Active Record's schema dumper when creating the database.
#     # This is necessary if your schema can't be completely dumped by the schema dumper,
#     # like if you have constraints or database-specific column types
#     # config.active_record.schema_format = :sql

#     # Enforce whitelist mode for mass assignment.
#     # This will create an empty whitelist of attributes available for mass-assignment for all models
#     # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
#     # parameters by using an attr_accessible or attr_protected declaration.
#     config.active_record.whitelist_attributes = true

#     # Enable the asset pipeline
#     config.assets.enabled = true

#     # Version of your assets, change this if you want to expire all your assets
#     config.assets.version = '1.0'
#   end
# end