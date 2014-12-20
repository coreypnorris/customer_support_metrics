require 'spec_helper'

RSpec.describe Dynamodb do

  before(:each) do
    @db = Dynamodb.new
    @test_table = @db.create_table('test_table')
    sleep 1 while @test_table.status == :creating
    @test_data_1 = '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}'
  end

  after(:each) do
    if @test_table.exists?
      unless @test_table.item_count == 0
        @test_table.items.each { |item| item.delete }
      end
      @test_table.delete
      sleep 1 while @test_table.exists? == true
    end
  end

  describe ".initialize" do
    it "configures AWS with the appropriate credentials" do
      @db.access_key_id == ENV['AWS_ACCESS_KEY_ID']
      @db.secret_access_key == ENV['AWS_SECRET_ACCESS_KEY']
      @db.region == ENV['AWS_REGION']
    end

    it 'stores a new instance of AWS' do
      expect(@db.aws).to eq AWS
    end

    it 'stores a new instance of AWS::DynamoDB' do
      expect(@db.client.class).to eq AWS::DynamoDB
    end
  end

  describe ".create_table" do
    it "creates a table with a custom name" do
      expect(@test_table.name).to eq 'test_table'
    end

    it "creates a table with an {:id => :number} hash key" do
      expect(@test_table.hash_key.name).to eq 'id'
      expect(@test_table.hash_key.type).to eq :number
    end

    it "automatically loads the schema for the table" do
      expect(@test_table.schema_loaded?).to eq true
    end

    context "table with the same name already exists" do
      it 'returns the existing table with the passed in name' do
        first_create = @db.create_table('test_table')
        second_create = @db.create_table('test_table')
        expect(first_create).to eq second_create
      end
    end
  end

  describe '.get_largest_id_from_table' do
    it 'returns a number equal to the largest id in a table' do
      @test_table.items.create('id' => 1, 'data' => @test_data_1)
      @test_table.items.create('id' => 2, 'data' => @test_data_1)
      @test_table.items.create('id' => 3, 'data' => @test_data_1)
      largest_id = @db.get_largest_id_from_table(@test_table)
      expect(largest_id).to eq 3
    end
  end

  describe ".insert_data" do
    it "inserts data into a table" do
      test_item = @db.insert_data(@test_table, @test_data_1)
      expect(test_item.attributes['data']).to eq @test_data_1
    end

    it "increases the id attribute by one for each new item" do
      test_data_2 = '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}'
      test_data_3 = '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}'

      test_item_1 = @db.insert_data(@test_table, @test_data_1)
      test_item_2 = @db.insert_data(@test_table, test_data_2)
      test_item_3 = @db.insert_data(@test_table, test_data_3)

      expect(test_item_1.attributes['id'].to_i).to eq 1
      expect(test_item_2.attributes['id'].to_i).to eq 2
      expect(test_item_3.attributes['id'].to_i).to eq 3
    end
  end
end
