module SlackMarketGame
  module Commands
    class Help < SlackRubyBot::Commands::Base
      HELP = <<-EOS
```
I am your friendly slack-market-game, here to help.

General
-------

help               - get this helpful message

```
EOS
      def self.call(client, data, _match)
        client.say(channel: data.channel, text: [HELP, SlackMarketGame::INFO].join("\n"))
        client.say(channel: data.channel, gif: 'help')
        logger.info "HELP: #{client.team}, user=#{data.user}"
      end
    end
  end
end
