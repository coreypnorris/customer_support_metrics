require 'sinatra'
require 'sinatra/base'
require 'logger'
require 'aws-sdk'
require 'dotenv'

Dotenv.load

Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }

class Reader < Sinatra::Base
  Logger.class_eval { alias :write :'<<' }

  access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)),'..','logger','access.log')
  access_logger = ::Logger.new(access_log)

  configure do
    use ::Rack::CommonLogger, access_logger
  end

  def self.insert_message_into_helpscout_table(message)
    dynamo_db = AWS::DynamoDB::Client::V20120810.new

    unless dynamo_db.list_tables[:table_names].include? 'helpscout_data'
      dynamo_db.create_table(
        table_name: "helpscout_data",
        attribute_definitions: [
          {attribute_name: "id", attribute_type: "S"},
          {attribute_name: "data", attribute_type: "S"}
        ],
        key_schema: [
          {attribute_name: "id", key_type: "HASH"},
          {attribute_name: "data", key_type: "RANGE"}
        ],
        provisioned_throughput: {
          read_capacity_units: 10,
          write_capacity_units: 10})
    end

    dynamo_db.put_item(:table_name => "helpscout_data", :item => {"id" => { "S" => SecureRandom.uuid }, "data" => { "S" => message }})
  end

  def self.create_helpscout_queue(configured_aws)
    configured_aws.sqs_client.create_queue(:queue_name => 'helpscout_data')

    sqs = AWS::SQS.new
    sqs.queues.named('helpscout_data')
  end

  get '/helpscout_queue_reader' do
    begin
      configured_aws = AWS.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
      helpscout_data_queue = Reader.create_helpscout_queue(configured_aws)

      helpscout_data_queue.poll do |msg|
        Reader.insert_message_into_helpscout_table(dynamo_db, msg.body)
        puts "#{msg.body} has been read from #{helpscout_data_queue.url} and inserted into Dynamodb #{helpscout_data_table.name} at #{Time.now}"
      end
    rescue => e
      puts '------------------------------------------------------------------------------------------rescuing helpscout_queue_reader'
      puts "Exception at #{Time.now}"
      puts e
      puts e.backtrace
      puts '------------------------------------------------------------------------------------------rescued helpscout_queue_reader'
    end
  end
end
