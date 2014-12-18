class Sqs
  def initialize
    @aws = AWS
    @aws.config(access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
    @client = AWS::SQS.new
  end

  def create_queue(name)
    @client.queues.create(name)
  end

  def connect_to_queue(name)
    @client.queues.named(name)
  end

  def list_queues
    @client.client.list_queues
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
