Sqs Reader
--
Creates an Amazon SQS queue and places any data from said queue into a Amazon Dynamodb nosql table.

Helpscout Webhook
--
Listens for POST requests from Helpscout and places the data in the SQS queue.

Transformer
--
Queries the Dynamodb table and parses/archives the data into


Instructions
--
1) Add credientials to .env files.

2) Start the Sqs Reader. This will create the helpscout_data SQS queue and start polling it for messages.

3) Start the Helpscout Webhook.

4) Start the Transformer.

If you want to run the rspec tests be aware that the Helpscout Webhook app relies on elasticmq to test the queue locally. So make sure you have that installed and running on port 9324 (the default port) if you want to run the tests successfully.


curl -H "Content-Type: application/json" -d '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}' http://localhost:9999/helpscout_webhook
