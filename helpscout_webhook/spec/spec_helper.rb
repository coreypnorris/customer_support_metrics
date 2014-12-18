require 'sinatra'
require 'vcr'
require 'rack/test'
require 'webmock/rspec'

require ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', 'app', 'webhook.rb')
require ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', 'app', 'sqs.rb')
require ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', 'config', 'environment.rb')

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
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
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  c.filter_sensitive_data('<access_key_id>') { ENV['AWS_ACCESS_KEY_ID'] }
  c.filter_sensitive_data('<secret_access_key>') { ENV['AWS_SECRET_ACCESS_KEY'] }
  c.filter_sensitive_data('<region>') { ENV['AWS_REGION'] }
  c.filter_sensitive_data('<region>') { ENV['AWS_ACCOUNT_NUMBER'] }
end
