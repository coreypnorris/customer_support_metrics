# Customer Support Metrics

This project was created to download, parse, archive, and display JSON data from the popular help desk app [Helpscout](http://www.helpscout.net/). The project contains three different apps: the helpscout_webhook and transformer both written in Sinatra, and metrics which is written in [Shopify's Dashing](http://www.dashing.io/).

## Helpscout Webhook
Listens for POST requests from Helpscout and places the data into an Amazon SQS queue.

## Transformer
Reads the data from the SQS queue, parses the JSON, stores the data in postgres, and sends the data to the Metrics dashboards via POST.

## Metrics
This app contains the 4 dashboards. When running it recieves data via POST from the transformer and puts it up on the dashboards.

### Preview Image
![alt text](https://github.com/coreypnorris/customer_support_metrics/blob/master/dashboard_week_example.png "Preview Image")

## Setup

### THE .env files

This project requires 3 .env files in each of the apps. Not every enviornment variable is needed for all three apps, but for convienience you can have the save file in each app. It should look as follows:

```
WEBHOOK_SECRET_KEY=your_helpscout_webhook_secret_key
HELPSCOUT_USERNAME=your_helpscout_webhook_username
HELPSCOUT_PASSWORD=your_helpscout_webhook_password
AWS_ACCESS_KEY_ID=your_amazon_webservice_access_key_id
AWS_SECRET_ACCESS_KEY=your_amazon_webservice_secret_access_key_id
AWS_REGION=your_amazon_webservice_region
AWS_ACCOUNT_NUMBER=your_amazon_webservice_account_number
HELPSCOUT_SUPPORT_MAILBOX_ID=9999
HOLIDAYS: Memorial Day, New Year's Eve, New Years Day, Memorial Day, Fourth of July, Labor Day, Thanksgiving, Day after Thanksgiving, Christmas Eve, Christmas Day
HELPSCOUT_GOAL_BUSINESS_HOURS: 900
HELPSCOUT_GOAL_OFF_HOURS: 10800
BUSINESS_HOURS_OPEN: 6
BUSINESS_HOURS_CLOSE: 18
WEEKDAYS_OFF: 0, 6
TIME_ZONE: Pacific Time (US & Canada)
```

* The HELPSCOUT_SUPPORT_MAILBOX_ID is the id of the mailbox you're interested in getting metrics on.

* You can remove holidays from the HOLIDAYS list but if you want to add additional ones you'll need to add them to the code logic.

* The HELPSCOUT_GOAL variables deterimine in seconds what qualifies as an 'on-goal' conversation. Here the response time target during business hours is 15 minutes and off hours it's 3 hours.

* The BUSINESS_HOURS_OPEN/CLOSE variables are the company's business hours measured in military time.

* The WEEKDAYS_OFF are the days of the week your company takes off. 0 is Saturday and 6 is Sunday.

* The TIME_ZONE is your Ruby determined timezone.

## Starting the apps

* After creating the .env files you're ready to start the servers. Start with the webhook. Navigate to customer_support_metrics/helpscout_webhook in your terminal and start the server with the command `rackup config.ru`.

* Add the url and port that the Helpscout webhook server is running on to your helpscout_webhook integration url. The webhook app will now start storing your conversations in the SQS queue.

* Now we can start the server on the metrics app. Navigate to customer_support_metrics/metrics in your terminal and start the server with the command `dashing start`.

* Finally, we can start the transformer to begin downloading and proccessing the data in helpscout. Navigate to customer_support_metrics/transformer in your terminal and start the server with the command `rackup config.ru`. Then in your browser go to the url that the transformer is running on /admin.

* Here you'll find the controls. Click the Rebuild Helpscout Data button to begin downloading data from your Helpscout mailbox.

* Then click the Refill Widgets button. This will start a service that will automatically refresh the dashboards with the latest data every 10 minutes.

* And you're done with the setup! On the admin page you can click on the Dashboards dropdown in the navbar to get the links to your dashboards.
