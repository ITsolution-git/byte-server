require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])


# Used to track Deprication warnings
# Taken from here: __http__://autorevo.github.io/2014/03/01/find-deprecation-warnings-with-set_trace_func.html

# set_trace_func(Proc.new do |event, filename, line, object_id, binding, klass|
#   if event == 'c-call' && object_id.to_s == 'warn'
#     puts "#{klass}##{object_id} #{filename}:#{line}"
#     puts caller[0,5].join("\n")
#   end
# end)
