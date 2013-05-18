require File.expand_path('../boot', __FILE__)

require 'rails'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Dummy
  class Application < Rails::Application
    config.credentials_mode = "development"
  end
end
