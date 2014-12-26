require 'sinatra'
require 'sinatra/base'
require 'logger'
require 'aws-sdk'
require 'dotenv'

Dotenv.load

Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }
require File.dirname(__FILE__) + '/../../helpscout_webhook/app/sqs.rb'

class Reader < Sinatra::Base
  Logger.class_eval { alias :write :'<<' }

  access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)),'..','logger','access.log')
  access_logger = ::Logger.new(access_log)

  configure do
    use ::Rack::CommonLogger, access_logger
  end

  helpers do
    def get_largest_id_from_table(table)
      if table.items.count == 0
        item_ids = [0]
      else
        item_ids = []
        table.items.each { |item| item_ids << item.hash_value.to_i }
        item_ids.sort!.reverse!
      end

      item_ids.first
    end

    def insert_data(table, data)
      id = (get_largest_id_from_table(table) + 1)
      table.items.create('id' => id, 'data' => data)
    end
  end

  get '/helpscout_queue_reader' do
    begin
      configured_aws = AWS.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
      configured_aws.sqs_client.create_queue(:queue_name => 'helpscout_data')

      sqs = AWS::SQS.new
      helpscout_data_queue = sqs.queues.named('helpscout_data')

      dynamo_db = AWS::DynamoDB.new

      helpscout_data_queue.poll do |msg|
        unless dynamo_db.tables['helpscout_data'].exists?
          helpscout_data_table = dynamo_db.tables.create('helpscout_data', 10, 5, :hash_key => { :id => :number })
          sleep 1 while helpscout_data_table.status == :creating
        else
          helpscout_data_table = dynamo_db.tables['helpscout_data']
        end

        helpscout_data_table.load_schema
        insert_data(helpscout_data_table, msg.body)
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
