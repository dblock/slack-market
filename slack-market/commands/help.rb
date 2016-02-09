module SlackMarket
  module Commands
    class Help < SlackRubyBot::Commands::Base
      HELP = <<-EOS
```
I am your friendly market bot, providing Yahoo Finance data.
Try "What is the price of MSFT?" or "Tell me about YHOO, AAPL and $I, please."

General
-------

help                - get this helpful message

Settings
--------

set dollars on|off  - respond to $QUOTE, but not $QUOTE

```
EOS
      def self.call(client, data, _match)
        client.say(channel: data.channel, text: [HELP, SlackMarket::INFO].join("\n"))
        client.say(channel: data.channel, gif: 'help')
        logger.info "HELP: #{client.owner}, user=#{data.user}"
      end
    end
  end
end
