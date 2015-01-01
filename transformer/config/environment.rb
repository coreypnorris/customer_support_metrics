require "bundler"
require "rubygems"
require "active_support/deprecation"
require "active_support/all"
require 'pry'

Dir[File.dirname(__FILE__) + '/../app/*.rb'].each {|file| require file }

Bundler.require(:default)                   # load all the default gems
Bundler.require(Sinatra::Base.environment)  # load all the environment specific gems
