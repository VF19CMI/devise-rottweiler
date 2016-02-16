require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class RottweilerAuth < ::Devise::Strategies::Authenticatable
      def authenticate!
        resource = password.present? && mapping.to.find_for_database_authentication(authentication_hash) 
        resource.password = password
        if resource.valid_password?
          remember_me(resource)
          success!(resource)
        end 
        
        fail(:not_found_in_database) unless resource
      end
    end
  end
end


Warden::Strategies.add(:rottweiler_auth, Devise::Strategies::RottweilerAuth)

