module Rottweiler
  module Callbacks
    def rottweilerize
      class_eval do
        after_update :sync_with_rottweiler
        before_create :create_rottweiler_user

        def create_rottweiler_user
          if self.valid?
            response = rottweiler_client.create_user(whitelist_attr.merge({password: self.password}))
            if response.code == 200
              self.rottweiler_id = JSON(response.body)["id"]
            else
              false
            end
          end
        end
        def sync_with_rottweiler
          rottweiler_client.update_user({user_id: self.rottweiler_id, attributes: whitelist_attr}) 
        end
        def whitelist_attr
          wanted_keys = %w[first_name last_name email]
          attr = self.attributes.select {|key,_| wanted_keys.include? key}
          return attr.merge({password: password}) if !password.nil?
        end
        def rottweiler_client
          @_rottweiler_client = Rottweiler::Client.new(Devise.rottweiler_url)
        end
      end
    end
  end
end
