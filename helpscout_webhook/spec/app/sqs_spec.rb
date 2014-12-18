require 'spec_helper'
require 'json'

RSpec.describe Sqs, :vcr => true do
  let(:sqs) { Sqs.new }

  describe ".initialize" do
    it "configures AWS with the appropriate credentials" do
      sqs.access_key_id == ENV['AWS_ACCESS_KEY_ID']
      sqs.secret_access_key == ENV['AWS_SECRET_ACCESS_KEY']
      sqs.region == ENV['AWS_REGION']
    end
  end

  describe ".create_queue" do
    it "creates a queue with a custom name" do
      sqs.create_queue('test')
      expect(sqs.list_queues[:queue_urls].any? { |url| url.include?('test') }).to eq true
    end
  end

  describe ".connect_to_queue" do
    it "returns a queue with the name passed to it" do
       sqs.create_queue('test')
       test_queue = sqs.connect_to_queue('test')
       expect(test_queue.exists?).to eq true
    end
  end

  describe ".list_queues" do
    it "returns a hash with an array containing the urls of all the created queues" do
      queue_names = ['test_1', 'test_2', 'test_3']

      queue_names.each do |name|
        sqs.create_queue(name)
      end

      queue_names.each do |name|
        test_queue_url = "https://sqs.#{ENV['AWS_REGION']}.amazonaws.com/#{ENV['AWS_ACCOUNT_NUMBER'].gsub('-','')}/#{name}"
        expect(sqs.list_queues[:queue_urls].any? { |queue_url| queue_url == test_queue_url }).to eq true
      end
    end
  end

  describe ".access_key_id" do
    it "returns the access key of the configured aws client" do
      expect(sqs.access_key_id).to eq ENV['AWS_ACCESS_KEY_ID']
    end
  end

  describe ".secret_access_key" do
    it "returns the secret access key of the configured aws client" do
      expect(sqs.secret_access_key).to eq ENV['AWS_SECRET_ACCESS_KEY']
    end
  end

  describe ".region" do
    it "returns the region of the configured aws client" do
      expect(sqs.region).to eq ENV['AWS_REGION']
    end
  end

end
