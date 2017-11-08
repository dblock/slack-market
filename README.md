Slack Market
============

[![Build Status](https://travis-ci.org/dblock/slack-market.svg?branch=master)](https://travis-ci.org/dblock/slack-market)
[![Dependency Status](https://gemnasium.com/dblock/slack-market.svg)](https://gemnasium.com/dblock/slack-market)
[![Code Climate](https://codeclimate.com/github/dblock/slack-market.svg)](https://codeclimate.com/github/dblock/slack-market)

A stock market and crypto currencies bot for Slack.

## Install

[![Add to Slack](https://platform.slack-edge.com/img/add_to_slack.png)](http://market.playplay.io)

Invite *@market* to a channel with `/invite @market`.

## Usage

### Quotes from Google Finance

Mention a stock ticker, eg. `MSFT`, and get a quote. Works for some crypto-currencies, eg. `BTC`. Single-character stocks should include a $ sign, eg. `$F`.

![](public/img/market.gif)

### Bought and Sold

Record when you buy and sell stock.

#### bought [symbol]

Announce that you bought a symbol.

#### sold [symbol]

Announce that you sold a symbol.

#### positions [user]

Display current positions. Optionally specify a user to display someone else's current positions.

#### Interactive Chart Buttons

Update a message to render charts for a stock's value over the course of one day, one month and one year.

![](public/img/interactive-chart.gif)

### Settings

#### set dollars on|off

Set to `on` to respond to `$MSFT`, but not `MSFT`.

![](public/img/dollars.gif)

#### set charts on|off

Set to `off` to turn off charts.

![](public/img/charts.gif)

### Subscription

#### subscription

Provides subscription info and a link to update the credit card on file.

### Copyright & License

Copyright [Daniel Doubrovkine](http://code.dblock.org), 2016-2017

[MIT License](LICENSE)
