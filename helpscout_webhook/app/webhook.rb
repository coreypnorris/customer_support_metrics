require 'sinatra'
require 'sinatra/base'
require 'pry'
require 'base64'
require 'hmac-sha1'
require 'dotenv'
require 'rufus-scheduler'
require 'json'
require 'net/http'
require 'logger'
require 'aws-sdk'

require ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', 'app', 'sqs.rb')

Dotenv.load

class Webhook < Sinatra::Base
  Logger.class_eval { alias :write :'<<' }

  access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)),'..','logger','access.log')
  access_logger = ::Logger.new(access_log)

  configure do
    use ::Rack::CommonLogger, access_logger
  end

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
    request.body.rewind

    begin
      puts "POST request proccessing started at #{Time.now}"
      body = request.body.read

      if body.empty?
        return 401
      end

      signature = helpscout_signature(body)

      if is_from_help_scout?(body, signature)
        sqs = Sqs.new
        queue = sqs.create_queue('helpscout_data')
        queue.send_message(body)
        puts "POST request data sent to helpscout_data queue at #{Time.now}"
        return 200
      else
        return 401
      end
    rescue => e
      puts '------------------------------------------------------------------------------------------rescuing method'
      puts "Exception at #{Time.now}"
      puts e
      puts e.backtrace
      puts '------------------------------------------------------------------------------------------rescued method'
    end
  end
end
