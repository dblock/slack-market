module SlackMarket
  class Server < SlackRubyBotServer::Server
    CHANNEL_JOINED_MESSAGE = <<-EOS.freeze
Thanks for installing Slack Market! Mention a ticker (eg. YHOO) and I'll give you a quote and a chart.
Track stocks with `@market bought` and `@market sold`. Type `@market help` for more commands.

_Buy low and sell high!_
    EOS

    on :channel_joined do |client, data|
      logger.info "#{client.owner.name}: joined ##{data.channel['name']}."
      client.say(channel: data.channel['id'], text: CHANNEL_JOINED_MESSAGE)
    end
  end
end
