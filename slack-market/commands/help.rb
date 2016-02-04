module SlackMarket
  module Commands
    class Help < SlackRubyBot::Commands::Base
      HELP = <<-EOS
```
I am your friendly market bot, providing Yahoo Finance data.

Market
------

Try _What is the price of MSFT?_ or _Tell me about YHOO and AAPL, please._

General
-------

help               - get this helpful message

```
EOS
      def self.call(client, data, _match)
        client.say(channel: data.channel, text: [HELP, SlackMarket::INFO].join("\n"))
        client.say(channel: data.channel, gif: 'help')
        logger.info "HELP: #{client.team}, user=#{data.user}"
      end
    end
  end
end
