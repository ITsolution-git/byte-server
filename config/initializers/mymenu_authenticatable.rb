# require 'devise/strategies/authenticatable'

# module Devise
#   module Strategies
#     class MyMenuAuthenticatable < Authenticatable
#       def authenticate!
#         authentication_hash[:password] = password
#         resource = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
#         return fail(:not_found_in_database) unless resource
#         if validate(resource){ resource.valid_password?(password) }
#           resource.after_database_authentication
#           success!(resource)
#         end
#       end
#     end
#   end
# end

# Warden::Strategies.add(:mymenu_authenticatable, Devise::Strategies::MyMenuAuthenticatable)
