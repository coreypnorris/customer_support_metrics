require ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..', '..', 'helpscout_webhook', 'app', 'sqs.rb')
require ::File.join(::File.dirname(::File.expand_path(__FILE__)), 'dynamodb.rb')

class Reader
  def initialize
    @aws = AWS
    @aws.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
  end

  def send_data_in_queue_to_table(queue, table, loop)
    begin
      db = Dynamodb.new

      queue.poll(:idle_timeout => 10) do |data|
        db.insert_data(table, data.body)
        puts "SQS Queue #{queue.url} has inserted #{data.body} into Dynamodb #{table.name} at #{Time.now}"
      end
    rescue => e
      puts '------------------------------------------------------------------------------------------rescuing send_data_in_queue_to_table'
      puts "Exception at #{Time.now}"
      puts e
      puts e.backtrace
      puts '------------------------------------------------------------------------------------------rescued send_data_in_queue_to_table'
    end while loop == true
  end

  def aws
    @aws
  end

  def access_key_id
    @aws.config.access_key_id
  end

  def secret_access_key
    @aws.config.secret_access_key
  end

  def region
    @aws.config.region
  end
end
