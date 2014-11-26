require 'simplecov'
require 'coveralls'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'paperclip/matchers'
require 'cancan/matchers'
require 'database_cleaner'
require 'public_activity/testing'

PublicActivity.enabled = false

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/*.rb')].each { |f| require f }

def load_factories
  # temporary fix to include factory_girl until we do it the right way
  Dir[Rails.root.join('spec/support/factories/**/*.rb')].each { |f| load f } unless Rails.env.production?
end

load_factories

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.order = 'random'

  config.include Paperclip::Shoulda::Matchers

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.include Devise::TestHelpers, :type => :controller
  config.include ControllerMacros, :type => :controller
end
