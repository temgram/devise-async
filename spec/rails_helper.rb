ENV['RAILS_ENV'] ||= 'test'

require 'action_controller'

require 'devise'
require 'devise/async'
require 'rails/all'

require 'spec_helper'
require 'rspec/rails'
require 'pry'

require 'support/rails_app'
require 'support/test_helpers'
require 'support/my_mailer'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include TestHelpers

  config.before :suite do
    load File.dirname(__FILE__) + '/support/rails_app/db/schema.rb'
  end
end

I18n.enforce_available_locales = false
