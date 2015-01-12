require 'sinatra'
require 'sinatra/base'
require 'active_record'
require 'date'
require 'logger'
require 'aws-sdk'
require 'dotenv'
require 'httparty'
require 'rufus-scheduler'

Dir[File.dirname(__FILE__) + '/../lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require_relative file }

Dotenv.load

class Admin < Sinatra::Base
  set :views, Proc.new { ::File.join(::File.dirname(::File.expand_path(__FILE__)),'..','views') }

  helpers do
    def humanize_seconds(seconds)
      [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
        if seconds > 0
          seconds, n = seconds.divmod(count)
          "#{n.to_i} #{name}"
        end
      }.compact.reverse.join(' ')
    end
  end

  get '/admin' do
    erb :admin
  end

  post '/rebuild_helpscout_data' do
    # schedule is used to enable redirect to /admin
    scheduler = Rufus::Scheduler.new

    scheduler.in '1s' do |job|
      truncate_tables
      # transform_helpscout_mailbox_data(ENV['HELPSCOUT_SUPPORT_MAILBOX_ID'])
      poll_helpscout_queue
    end

    redirect '/admin'
  end

  post '/widgets_refill' do
    empty_widgets

    send_helpscout_data_to_widgets

    scheduler = Rufus::Scheduler.new

    scheduler.every '10m' do |job|
      send_helpscout_data_to_widgets
    end

    redirect '/admin'
  end

  post '/lookup_conversations' do
    begin
      if params[:metrics_time_range] != ''
        @conversations = get_collection_by_metric_range(params[:metrics_time_range], ConversationMetric, :created_at).order('first_response_duration DESC NULLS LAST')
        @time_range = params[:metrics_time_range].gsub('_', ' ').capitalize
      elsif (params['custom_range_start'] != "") && (params['custom_range_end'] != '')
        @conversations = ConversationMetric.where(:created_at => params['custom_range_start'].to_date.beginning_of_day..params['custom_range_end'].to_date.end_of_day).order('first_response_duration DESC NULLS LAST')
        @time_range = "#{params['custom_range_start']} - #{params['custom_range_end']}"
      elsif params['custom_range_start'] != ''
        @conversations = ConversationMetric.where(:created_at => params['custom_range_start'].to_date).order('first_response_duration DESC NULLS LAST')
        @time_range = "#{params['custom_range_start']}"
      end

      @business_hours_conversations = @conversations.where(:during_business_hours => true, :special_case => false)
      @off_hours_conversations = @conversations.where(:during_business_hours => false)
      @special_case_conversations = @conversations.where(:special_case => true)

      @num_on_goal = get_num_on_goal(@conversations)
      @num_off_goal = get_num_off_goal(@conversations)

      @avg_rt_business_hours = humanize_seconds(@business_hours_conversations.average(:first_response_duration))
      @slowest_rt_business_hours = humanize_seconds(@business_hours_conversations.maximum(:first_response_duration))

      @avg_rt_off_hours = humanize_seconds(@conversations.average(:first_response_duration))
      @slowest_rt_off_hours = humanize_seconds(@conversations.maximum(:first_response_duration))

      erb :'form_results'
    rescue => e
      puts '------------------------------------------------------------------------------------------rescuing POST to admin/conversations'
      puts "Exception at #{Time.now}"
      puts e
      puts e.backtrace
      puts '------------------------------------------------------------------------------------------rescued POST to admin/conversations'
    end
  end
end
