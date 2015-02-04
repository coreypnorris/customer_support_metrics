require 'sinatra'
require 'sinatra/base'
require 'pry'
require 'base64'
require 'hmac-sha1'
require 'dotenv'
require 'json'
require 'net/http'
require 'logger'
require 'aws-sdk'

Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }

Dotenv.load

class Webhook < Sinatra::Base
  helpers do
    def is_from_help_scout?(data, signature)
      return false if data.nil? || signature.nil?
      hmac = OpenSSL::HMAC.digest('sha1', ENV['WEBHOOK_SECRET_KEY'], data)
      Base64.encode64(hmac).strip == signature.strip
    end

    def helpscout_signature(data)
      hmac = OpenSSL::HMAC.digest('sha1', ENV['WEBHOOK_SECRET_KEY'], data)
      Base64.encode64(hmac.strip)
    end
  end

  def self.get_helpscout_data_queue
    if ENV['RACK_ENV'] == 'test'
      configured_aws = AWS.config(:sqs_endpoint => 'localhost', :sqs_port => 9324, :use_ssl => false)
    else
      configured_aws = AWS.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
    end

    sqs_client = AWS::SQS.new
    sqs_client.queues.create('helpscout_webhook_data')
  end

  post '/helpscout_webhook' do
    begin
      request.body.rewind

      body = request.body.read

      if body.empty?
        return 401
      end

      signature = helpscout_signature(body)

      if is_from_help_scout?(body, signature)
        helpscout_data_queue = Webhook.get_helpscout_data_queue
        sent_message = helpscout_data_queue.send_message(body)
        puts "Message #{sent_message.message_id} sent to #{helpscout_data_queue.url} at #{Time.now}"

        return 200
      else
        return 401
      end
    rescue => e
      puts '------------------------------------------------------------------------------------------rescuing POST to webhook'
      puts "Exception at #{Time.now}"
      puts e
      puts e.backtrace
      puts '------------------------------------------------------------------------------------------rescued POST to webhook'
    end
  end
end
