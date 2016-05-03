module Rottweiler
  module Callbacks
    def rottweilerize
      class_eval do
        after_update :sync_with_rottweiler
        before_create :create_rottweiler_user, unless: :rottweiler_user_already_exists
        validate :email_is_not_taken_in_rottweiler, on: :create, unless: :rottweiler_user_already_exists
        
        def email_is_not_taken_in_rottweiler
          response = rottweiler_client.check_user({email: self.email})
          self.errors.add(:email, 'already exists :)') if response.code == 200
        end
        
        def create_rottweiler_user
          if self.valid?
            response = rottweiler_client.create_user(whitelist_attr.merge({password: self.password}))
            if response.code == 200
              self.rottweiler_id = JSON(response.body)["id"]
            end
          end
        end
        def sync_with_rottweiler
          if !changed.grep(/^first_name|last_name|email|avatar_file_name$/).empty? || !password.nil?
            rottweiler_client.update_user({user_id: self.rottweiler_id, attributes: whitelist_attr}) 
          end
        end
        def whitelist_attr
          wanted_keys = %w[first_name last_name email]
          attr = self.attributes.select {|key,_| wanted_keys.include? key}
          attr.merge!({password: password}) if !password.nil?
          attr.merge!({avatar_url: self.avatar.url}) if self.respond_to?(:avatar)
          return attr
        end
        def rottweiler_client
          @_rottweiler_client = Rottweiler::Client.new(Devise.rottweiler_url)
        end
      end
    end
  end
end
