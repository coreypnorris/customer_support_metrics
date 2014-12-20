require 'spec_helper'

RSpec.describe Reader do

  before(:each) do
    @reader = Reader.new

    @sqs = Sqs.new
    @test_queue = @sqs.create_queue('test_queue')
    @test_data = '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}'
    @test_queue.send_message(@test_data)

    @db = Dynamodb.new
    @test_table = @db.create_table('test_table')
    sleep 1 while @test_table.status == :creating
  end

  after(:each) do
    if (@test_table) && (@test_table.exists?)
      unless @test_table.item_count == 0
        @test_table.items.each { |item| item.delete }
      end
      @test_table.delete
      sleep 1 while @test_table.exists? == true
    end
  end

  describe ".initialize" do
    it "configures AWS with the appropriate credentials" do
      @reader.access_key_id == ENV['AWS_ACCESS_KEY_ID']
      @reader.secret_access_key == ENV['AWS_SECRET_ACCESS_KEY']
      @reader.region == ENV['AWS_REGION']
    end
  end

  describe '.send_data_in_queue_to_table' do
    it "polls the queue for data and places it into the helpscout_data Dynamodb table" do
      @reader.send_data_in_queue_to_table(@test_queue, @test_table, false)
      expect(@test_table.items.count).to eq 1
      expect(@test_table.items.first.attributes['id']).to eq 1
      expect(@test_table.items.first.attributes['data']).to eq @test_data
    end
  end
end
