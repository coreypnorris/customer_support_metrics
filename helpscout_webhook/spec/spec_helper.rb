require 'sinatra'
require 'rack/test'
require 'webmock/rspec'

Dir[File.dirname(__FILE__) + '/../app/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/../config/environment.rb'].each {|file| require file }

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  WebMock.disable_net_connect!(allow_localhost: true)

  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  config.warnings = false

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  AWS.config(:sqs_endpoint => 'localhost', :sqs_port => 9324, :use_ssl => false)
end
