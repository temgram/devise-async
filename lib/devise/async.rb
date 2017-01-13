require 'devise'
require 'active_support/dependencies'
require 'devise/async/model'
require 'devise/async/version'

module Devise
  module Async
    # autoload :Model,   'devise/async/model'

    # Defines the enabled configuration that if set to false the emails will be sent synchronously
    mattr_accessor :enabled
    @@enabled = true

    # Allow configuring Devise::Async with a block
    #
    # Example:
    #
    #     Devise::Async.setup do |config|
    #       config.enabled = false
    #     end
    def self.setup
      yield self
    end
  end
end

# Register devise-async model in Devise
Devise.add_module(:async, model: 'devise/async/model')
