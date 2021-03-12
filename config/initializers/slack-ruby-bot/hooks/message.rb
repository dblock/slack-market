module SlackRubyBot
  module Hooks
    class Message
      # HACK: order command classes predictably
      def command_classes
        [
          SlackMarket::Commands::Sold,
          SlackMarket::Commands::Bought,
          SlackMarket::Commands::Sucks,
          SlackMarket::Commands::Set,
          SlackMarket::Commands::Positions,
          SlackMarket::Commands::Help,
          SlackMarket::Commands::Info,
          SlackMarket::Commands::Quote,
          SlackMarket::Commands::Subscription
        ]
      end

      alias_method :_call, :call

      def call(client, data)
        data.text = data.attachments&.map(&:fallback)&.join("\n") if data.text.blank?
        _call(client, data)
      end
    end
  end
end
