module SlackMarket
  module Commands
    class Set < SlackRubyBot::Commands::Base
      def self.call(client, data, match)
        if !match.names.include?('expression')
          client.say(channel: data.channel, text: 'Missing setting, eg. _set dollars on_.', gif: 'help')
          logger.info "SET: #{client.owner} - failed, missing setting"
        else
          k, v = match['expression'].split(/\W+/, 2)
          case k
          when 'dollars' then
            client.owner.update_attributes!(dollars: v.to_b) unless v.nil?
            client.say(channel: data.channel, text: "Dollar signs for team #{client.owner.name} are #{client.owner.dollars? ? 'on!' : 'off.'}", gif: 'dollars')
            logger.info "SET: #{client.owner} - dollar signs are #{client.owner.dollars? ? 'on' : 'off'}"
          else
            fail "Invalid setting #{k}, you can _set dollars on|off_."
          end
        end
      end
    end
  end
end
