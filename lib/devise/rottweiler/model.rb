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
        attr_reader :current_password
        attr_accessor :password
      end
    
      def valid_password?
        rottweiler_client.validate_credentials({email: email, password: password})
      end
      
      def update_with_password(params, *options)
        current_password = params.delete(:current_password)

        if params[:password].blank?
          params.delete(:password)
          params.delete(:password_confirmation) if params[:password_confirmation].blank?
        end
        result = if rottweiler_client.validate_credentials({email: email, password: current_password})
          update_attributes(params, *options)
        else
          self.assign_attributes(params, *options)
          self.valid?
          self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
          false
        end

        clean_up_passwords
        result
      end

      def clean_up_passwords
        self.password_confirmation = nil
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
