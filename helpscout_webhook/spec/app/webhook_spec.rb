require 'spec_helper'
require 'json'

RSpec.describe Webhook do
  def app
    Webhook
  end

  describe "POST /helpscout_webhook" do
    let(:body) { { :data => '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}' }.to_json }

    before(:all) do
      sqs_client = AWS::SQS::Client::V20121105.new
      sqs_client.create_queue(:queue_name => 'helpscout_data')
    end

    context "legitamate helpscout data" do
      before(:each) do
        post '/helpscout_webhook', body
      end

      it "returns status 200" do
        expect(last_response.status).to eq 200
      end

      it "sends the helpscout data to the sqs queue" do
        sqs_client = AWS::SQS::Client::V20121105.new
        message = sqs_client.receive_message(:queue_url => 'http://localhost:9324/queue/helpscout_data')[:messages].last
        expect(message[:body]).to eq body
      end
    end

    context "nil data" do
      it "returns status 401" do
        post '/helpscout_webhook'
        expect(last_response.status).to eq 401
      end
    end

    context "incorrect/wrong/bad data" do
      it "returns status 401" do
        body = { :data => '{"ticket":{"id":"8397428734928743298742903784","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}'  }.to_json
        post '/helpscout_webhook', body
        expect(last_response.status).to eq 401
      end
    end
  end
end
