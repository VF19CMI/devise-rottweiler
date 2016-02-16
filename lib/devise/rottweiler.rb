require "devise/rottweiler/version"
require "devise"
require "devise/rottweiler/strategy"
require "devise/rottweiler/callbacks"
module Devise
@@rottweiler_url = nil

mattr_accessor :rottweiler_url
end

Devise.add_module :rottweiler_auth,
  strategy: true,
  model: "devise/rottweiler/model",
  controller: :sessions,
  route: { session: :routes }

ActiveModel::Callbacks.send(:include, Rottweiler::Callbacks)
ActiveRecord::Base.send(:extend, Rottweiler::Callbacks) if defined?(ActiveRecord)
