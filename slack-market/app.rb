# TODO: remove after https://github.com/dblock/slack-ruby-bot-server/issues/22 is fixed
module SlackRubyBotServer
  class App
    def self.instance
      @instance ||= new
    end
  end
end

module SlackMarket
  class App < SlackRubyBotServer::App
    def prepare!
      super
      deactivate_asleep_teams!
    end

    private

    def deactivate_asleep_teams!
      Team.active.each do |team|
        next unless team.asleep?
        begin
          team.deactivate!
          team.inform! "This integration hasn't been used for 2 weeks, deactivating. Reactivate at https://market.playplay.io. Your data will be purged in another 2 weeks."
        rescue StandardError => e
          logger.warn "Error informing team #{team}, #{e.message}."
        end
      end
    end
  end
end
