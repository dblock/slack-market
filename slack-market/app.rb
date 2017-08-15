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
          team.inform! "This integration hasn't been used for 2 weeks, deactivating. Reactivate at #{SlackMarket::Service.url}. Your data will be purged in another 2 weeks."
        rescue StandardError => e
          logger.warn "Error informing team #{team}, #{e.message}."
        end
      end
    end
  end
end
