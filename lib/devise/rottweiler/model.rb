require 'devise/models'
require 'rottweiler/client'

def rottweiler_client
  @_rottweiler_client = Rottweiler::Client.new(Devise.rottweiler_url)
end

module Devise
  module Models
    module RottweilerAuth
      extend ActiveSupport::Concern
      
      included do
        attr_accessor :password
      end
    
      def valid_password?
        rottweiler_client.validate_credentials({email: email, password: password})
      end

      protected
      module ClassMethods
        def find_for_database_authentication(conditions)
          db = find_for_authentication(conditions)
          rottweiler = rottweiler_client.check_user(conditions)
          if db.nil?
            nil 
          else
            db
          end
        end
      end
    end
  end
end
