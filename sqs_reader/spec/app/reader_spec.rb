require 'spec_helper'
require 'aws-sdk-core'

RSpec.describe Reader do
  def app
    Reader
  end

  describe "self.insert_message_into_helpscout_table" do
    let(:dynamo_db) { AWS::DynamoDB::Client::V20120810.new }
    let(:message) { '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}' }

    before(:all) do
      AWS.config(:sqs_endpoint => 'localhost', :sqs_port => 9324, :dynamo_db_endpoint => 'localhost', :dynamo_db_port => 8000, :use_ssl => false)
      dynamo_db = AWS::DynamoDB::Client::V20120810.new

      if dynamo_db.list_tables[:table_names].include? 'helpscout_data'
        dynamo_db.delete_table(:table_name => 'helpscout_data')
      end
    end

    before(:each) do
      Reader.insert_message_into_helpscout_table(message)
    end

    after(:all) do
      dynamo_db = AWS::DynamoDB::Client::V20120810.new

      if dynamo_db.list_tables[:table_names].include? 'helpscout_data'
        dynamo_db.delete_table(:table_name => 'helpscout_data')
      end
    end

    it 'creates a DynamoDB table named helpscout_data' do
      dynamo_db_tables = dynamo_db.list_tables[:table_names]
      expect(dynamo_db_tables.include? 'helpscout_data').to eq true
    end

    it 'inserts a message into the helpscout_data DynamoDB table' do
      helpscout_data_table = dynamo_db.scan(:table_name => 'helpscout_data')
      first_item = helpscout_data_table[:member].first
      helpscout_data_table[:member].first['data'][:s]

      expect(first_item['data'][:s]).to eq message
    end
  end

  describe "self.create_helpscout_queue" do
    it 'returns an SQS queue named helpscout_data' do
      configured_aws = AWS.config(:sqs_endpoint => 'localhost', :sqs_port => 9324, :dynamo_db_endpoint => 'localhost', :dynamo_db_port => 8000, :use_ssl => false)
      helpscout_data_queue = Reader.create_helpscout_queue(configured_aws)

      expect(helpscout_data_queue.exists?).to eq true
    end
  end
end
