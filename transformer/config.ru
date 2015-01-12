require 'pry'
require ::File.join(::File.dirname(::File.expand_path(__FILE__)),'app','admin.rb')
#\ -p 9997

database_configurations = YAML::load(File.open(::File.join(::File.dirname(::File.expand_path(__FILE__)),'db','config.yml')))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

run Admin
