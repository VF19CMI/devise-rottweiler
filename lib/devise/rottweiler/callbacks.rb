module Rottweiler
  module Callbacks
    def rottweilerize
      class_eval do
        after_save :sync_with_rottweiler
        def sync_with_rottweiler
          rottweiler_client.update_user({user_id: self.rottweiler_id, attributes: whitelist_attr}) 
        end
        def whitelist_attr
          wanted_keys = %w[first_name last_name email]
          self.attributes.select {|key,_| wanted_keys.include? key}
        end
        def rottweiler_client
          @_rottweiler_client = Rottweiler::Client.new(Devise.rottweiler_url)
        end
      end
    end
  end
end
