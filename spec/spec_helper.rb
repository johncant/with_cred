require 'rubygems'
require 'bundler/setup'

require File.expand_path('../dummy/config/environment.rb', __FILE__)

RSpec.configure do |config|
  WithCred.deconfigure
end
