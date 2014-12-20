require 'aws-sdk'
require 'dotenv'
require 'pry'

Dotenv.load

class Dynamodb
  def initialize
    @aws = AWS
    @aws.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
    @client = AWS::DynamoDB.new
  end

  def create_table(table_name)
    begin
      if @client.tables[table_name].exists?
        table = @client.tables[table_name]
      else
        table = @client.tables.create( table_name, 10, 5, :hash_key => { :id => :number })
      end

      table.load_schema
    rescue => e
      puts e
      puts e.backtrace
    end
  end

  def get_largest_id_from_table(table)
    begin
      if table.items.count == 0
        item_ids = [0]
      else
        item_ids = []
        table.items.each { |item| item_ids << item.hash_value.to_i }
        item_ids.sort!.reverse!
      end

      item_ids.first
    rescue => e
      puts e
      puts e.backtrace
    end
  end

  def insert_data(table, data)
    begin
      id = (get_largest_id_from_table(table) + 1)
      table.items.create('id' => id, 'data' => data)
    rescue => e
      puts e
      puts e.backtrace
    end
  end

  def aws
    @aws
  end

  def access_key_id
    @aws.config.access_key_id
  end

  def secret_access_key
    @aws.config.secret_access_key
  end

  def region
    @aws.config.region
  end

  def client
    @client
  end
end
