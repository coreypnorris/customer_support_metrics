def poll_helpscout_queue
  begin
    puts "poll_helpscout_queue method started at #{Time.now}"

    configured_aws = AWS.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
    configured_aws.sqs_client.create_queue(:queue_name => 'helpscout_data')

    sqs = AWS::SQS.new
    helpscout_data_queue = sqs.queues.named('helpscout_webhook_data')

    helpscout_data_queue.poll do |msg|
      parsed_msg = JSON.parse(msg.body)
      
      if (parsed_msg.keys.count == 1) && (parsed_msg.keys.first == 'id')
        ConversationMetric.where(:id => parsed_msg['id']).destroy_all
        ConversationTag.where(:conversation_id => parsed_msg['id']).destroy_all
        ConversationThread.where(:conversation_id => parsed_msg['id']).destroy_all
        Conversation.where(:id => parsed_msg['id']).destroy_all
      else
        transform_helpscout_conversation(parsed_msg)
      end
    end
  rescue => e
    puts "------------------------------------------------------------------------------------------rescuing poll_helpscout_queue"
    puts "Exception at #{Time.now}"
    puts e
    puts e.backtrace
    puts "------------------------------------------------------------------------------------------rescued poll_helpscout_queue"
  end
end
