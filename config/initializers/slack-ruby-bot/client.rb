module SlackRubyBot
  class Client < Slack::RealTime::Client
    alias :_allow_bot_messages? :allow_bot_messages?

    def message_to_self?(data)
      !!(self.self && self.self.id == data.user)
    end

    def allow_bot_messages?
      _allow_bot_messages? || owner.reload.bots
    end
  end
end
