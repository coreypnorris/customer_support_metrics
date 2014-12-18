require ::File.join(::File.dirname(::File.expand_path(__FILE__)),'app','webhook.rb')
#\ -p 9999

run Webhook


# curl -H "Content-Type: application/json" -d '{"ticket":{"id":"1","number":"2"},"customer":{"id":"1","fname":"Jackie","lname":"Chan","email":"jackie.chan@somewhere.com","emails":["jackie.chan@somewhere.com"]}}' http://localhost:9999/helpscout_webhook
