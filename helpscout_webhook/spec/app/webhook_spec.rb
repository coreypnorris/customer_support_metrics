require 'spec_helper'
require 'json'

RSpec.describe Webhook, :vcr => true do
  def app
    Webhook
  end

  describe "POST /helpscout_webhook" do
    let(:body) { { :data => '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}' }.to_json }
    let(:convo_created_headers) { {'Content-Type' => 'application/json', 'X-HelpScout-Event' => 'convo.created'} }
    let(:sqs) { Sqs.new }

    context "legitamate helpscout data" do
      before(:each) do
        post '/helpscout_webhook', body, convo_created_headers
      end

      it "returns status 200" do
        expect(last_response.status).to eq 200
      end

      it "creates/connects to an SQS queue named helpscout_data" do
        expect(Sqs.new.list_queues[:queue_urls].any? { |url| url.include?('helpscout_data') }).to eq true
      end

      it "puts the parsed json into the helpscout_data queue" do
        messages = []
        queue = Sqs.new.connect_to_queue('helpscout_data')
        messages = queue.receive_messages
        expect(messages.body).to eq JSON.parse(body)['data']
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
        post '/helpscout_webhook'
        expect(last_response.status).to eq 401
      end
    end
  end
end
