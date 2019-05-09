module SlackMarket
  module Commands
    class Info < SlackRubyBot::Commands::Base
      INFO = <<~EOS.freeze
        Slack Market #{SlackMarket::VERSION}

        © 2016-2017 Daniel Doubrovkine, Vestris LLC & Contributors, MIT License
        https://www.vestris.com

        Service at #{SlackRubyBotServer::Service.url}
        Open-Source at https://github.com/dblock/slack-market
      EOS

      def self.call(client, data, _match)
        client.say(channel: data.channel, text: [
          SlackMarket::Commands::Info::INFO,
          client.owner.reload.subscribed? ? nil : client.owner.subscribe_text
        ].compact.join("\n"))
        client.say(channel: data.channel)
        logger.info "INFO: #{client.owner}, user=#{data.user}"
      end
    end
  end
end
