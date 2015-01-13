# Customer Support Metrics

This project was created to download, parse, archive, and display JSON data from the popular web-based help desk app [Helpscout](http://www.helpscout.net/). The project contains three different apps: the helpscout_webhook and transformer both written in Sinatra, and metrics which is written in [Shopify's Dashing](http://www.dashing.io/).

## Helpscout Webhook
Listens for POST requests from Helpscout and places the data into an Amazon SQS queue.

## Transformer
Reads the data from the SQS queue, parses the JSON, stores the data in postgres, and sends the data to the Metrics dashboards via POST.

## Metrics
This app contains the 4 dashboards. When running it recieves data via POST from the transformer and puts it up on the dashboards.

