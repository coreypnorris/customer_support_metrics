require "bundler"
require "rubygems"
require "active_support/deprecation"
require "active_support/all"

require ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', 'app', 'webhook.rb')
require ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', 'app', 'sqs.rb')

Bundler.require(:default)                   # load all the default gems
Bundler.require(Sinatra::Base.environment)  # load all the environment specific gems
