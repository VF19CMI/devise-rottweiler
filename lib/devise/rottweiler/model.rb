require 'devise/models'
require 'rottweiler/client'
require "open-uri"
def rottweiler_client
  @_rottweiler_client = Rottweiler::Client.new(Devise.rottweiler_url)
end

def uri_parser(url)
  open(url) rescue nil
end

module Devise
  module Models
    module RottweilerAuth
      extend ActiveSupport::Concern
      
      included do
        attr_reader :current_password
        attr_accessor :password, :rottweiler_user_already_exists
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
        def find_in_rottweiler(conditions)
          rottweiler_client.check_user(conditions)
        end
        
        def find_for_database_authentication(conditions,password)
          local_user = find_for_authentication(conditions)
          return local_user if local_user.present?
          if rottweiler_client.validate_credentials(conditions.merge({password: password}))
            rottweiler_response = rottweiler_client.check_user(conditions)
            rottweiler_user = JSON(rottweiler_response.body)
            rottweiler_user.delete("encrypted_password")
            rottweiler_user["rottweiler_id"] = rottweiler_user.delete("id")
            avatar_url = uri_parser(rottweiler_user.delete("avatar_url")) 

            if find_by(rottweiler_id: rottweiler_user["rottweiler_id"]).present?
              db_user = find_by(rottweiler_id: rottweiler_user["rottweiler_id"])   
              db_user.update_attributes(rottweiler_user)
              return db_user
            else
              db_user = self.new(rottweiler_user.merge({password: "Bb12345678"})) #crappy fake password because of validation
              db_user.rottweiler_user_already_exists = true
              db_user.skip_confirmation!
              db_user.save!
              db_user.update_attributes(avatar: avatar_url) if db_user.respond_to?(:avatar)
              return db_user
            end
          else
            nil 
          end
        end
      end
    end
  end
end
