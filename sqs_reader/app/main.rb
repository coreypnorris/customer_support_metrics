require ::File.join(::File.dirname(::File.expand_path(__FILE__)), 'dynamodb.rb')
require ::File.join(::File.dirname(::File.expand_path(__FILE__)), 'reader.rb')

class Main
  def self.listen_to_helpscout_data_queue
    begin
      sqs = Sqs.new
      helpscout_data_queue = sqs.create_queue('helpscout_data')

      db = Dynamodb.new
      helpscout_data_table = db.create_table('helpscout_data')

      reader = Reader.new
      reader.send_data_in_queue_to_table(helpscout_data_queue, helpscout_data_table, true)
    rescue => e
      puts '------------------------------------------------------------------------------------------rescuing sqs_reader/app/main.rb'
      puts "Exception at #{Time.now}"
      puts e
      puts e.backtrace
      puts '------------------------------------------------------------------------------------------rescued sqs_reader/app/main.rb'
    end
  end
end
