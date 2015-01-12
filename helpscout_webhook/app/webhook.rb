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

  post '/helpscout_webhook' do
    begin
      request.body.rewind

      body = request.body.read

      if body.empty?
        return 401
      end

      signature = helpscout_signature(body)

      if is_from_help_scout?(body, signature)
        configured_aws = AWS.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
        sqs_client = configured_aws.sqs_client

        queue_url = sqs_client.get_queue_url(:queue_name => 'helpscout_data', :queue_owner_aws_account_id => ENV['AWS_ACCOUNT_NUMBER'])[:queue_url]
        message_id = sqs_client.send_message(:queue_url => queue_url, :message_body => body)[:message_id]

        puts "Message #{message_id} sent to helpscout_data SQS queue at #{Time.now}"
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
