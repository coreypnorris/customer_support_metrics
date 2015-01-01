require 'sinatra'
require 'rack/test'
require 'webmock/rspec'
require 'active_record'

Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/../config/environment.rb'].each {|file| require file }

require 'shoulda/matchers'

ENV['RACK_ENV'] = 'test'

database_configurations = YAML::load(File.open(::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', 'db','config.yml')))
development_configuration = database_configurations['test']
ActiveRecord::Base.establish_connection(development_configuration)

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

  config.after(:each) do
    Person.delete_all
    Conversation.delete_all
  end
end
