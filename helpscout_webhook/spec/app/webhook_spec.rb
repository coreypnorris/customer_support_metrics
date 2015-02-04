require 'spec_helper'
require 'json'

RSpec.describe Webhook do
  def app
    Webhook
  end

  describe 'POST /helpscout_webhook' do
    let(:body) { '{"id":2391938111,"type":"email","folder":"1234","isDraft":"false","number":349,"owner":{"id":1234,"firstName":"Jack","lastName":"Sprout","email":"jack.sprout@gmail.com","phone":null,"type":"user"},"mailbox":{"id":1234,"name":"My Mailbox"},"customer":{"id":29418,"firstName":"Vernon","lastName":"Bear","email":"vbear@mywork.com","phone":"800-555-1212","type":"customer"},"threadCount":4,"status":"active","subject":"I need help!","preview":"Hello, I tried to download the file off your site...","createdBy":{"id":29418,"firstName":"Vernon","lastName":"Bear","email":"vbear@mywork.com","phone":null,"type":"customer"},"createdAt":"2012-07-23T12:34:12Z","modifiedAt":"2012-07-24T20:18:33Z","closedAt":null,"closedBy":null,"source":{"type":"email","via":"customer"},"cc":["cc1@somewhere.com","cc2@somewhere.com"],"bcc":["bcc1@somewhere.com","bcc2@somewhere.com"],"tags":["tag1","tag2"],"threads":[{"id":88171881,"assignedTo":{"id":1234,"firstName":"Jack","lastName":"Sprout","email":"jack.sprout@gmail.com","phone":null,"type":"user"},"status":"active","createdAt":"2012-07-23T12:34:12Z","createdBy":{"id":1234,"firstName":"Jack","lastName":"Sprout","email":"jack.sprout@gmail.com","phone":null,"type":"user"},"source":{"type":"web","via":"user"},"type":"message","state":"published","customer":{"id":29418,"firstName":"Vernon","lastName":"Bear","email":"vbear@mywork.com","phone":"800-555-1212","type":"customer"},"fromMailbox":null,"body":"This is what I have to say. Thank you.","to":["customer@somewhere.com"],"cc":["cc1@somewhere.com","cc2@somewhere.com"],"bcc":["bcc1@somewhere.com","bcc2@somewhere.com"],"attachments":[{"id":12391,"mimeType":"image/jpeg","filename":"logo.jpg","size":22,"width":160,"height":160,"url":"https://secure.helpscout.net/some-url/logo.jpg"}],"tags":["tag1","tag2","tag3"]}]}' }

    # poll queue after each test to empty it out
    after(:each) do
      helpscout_data_queue = Webhook.get_helpscout_data_queue

      puts "Emptying queue for RSpec tests at #{Time.now}"
      helpscout_data_queue.poll(:idle_timeout => 1, :visibility_timeout => 1) do |msg|
        puts "#{helpscout_data_queue.approximate_number_of_messages.to_s} messages left"
      end
    end

    context 'legitamate helpscout data' do
      before(:each) do
        post '/helpscout_webhook', body
      end

      it 'returns status 200' do
        expect(last_response.status).to eq 200
      end

      it 'sends the helpscout data to the sqs queue' do
        helpscout_data_queue = Webhook.get_helpscout_data_queue
        message = helpscout_data_queue.receive_message
        expect(message.body).to eq body
      end
    end

    context 'nil data' do
      it 'returns status 401' do
        post '/helpscout_webhook'
        expect(last_response.status).to eq 401
      end
    end

    context 'incorrect/wrong/bad data' do
      it 'returns status 401' do
        bad_data = '{"ticket":{"id":"8397428734928743298742903784","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}'
        post '/helpscout_webhook', bad_data
        expect(last_response.status).to eq 401
      end
    end
  end
end
