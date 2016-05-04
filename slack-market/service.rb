module SlackMarket
  class Service
    include SlackRubyBot::Loggable

    def self.instance
      @instance ||= new
    end

    def initialize
      @services = {}
    end

    def start!(team)
      fail 'Token already known.' if @services.key?(team.token)
      logger.info "Starting team #{team}."
      server = SlackMarket::Server.new(team: team)
      @services[team.token] = server
      restart!(team, server)
    rescue StandardError => e
      logger.error e
    end

    def stop!(team)
      fail 'Token unknown.' unless @services.key?(team.token)
      logger.info "Stopping team #{team}."
      @services[team.token].stop!
      @services.delete(team.token)
    rescue StandardError => e
      logger.error e
    end

    def start_from_database!
      Team.active.each do |team|
        start!(team)
      end
    end

    def restart!(team, server, wait = 1)
      server.start_async
    rescue StandardError => e
      case e.message
      when 'account_inactive', 'invalid_auth' then
        logger.error "#{team.name}: #{e.message}, team will be deactivated."
        deactivate!(team)
      else
        logger.error "#{team.name}: #{e.message}, restarting in #{wait} second(s)."
        sleep(wait)
        restart! team, server, [wait * 2, 60].min
      end
    end

    def deactivate!(team)
      team.deactivate!
      @services.delete(team.token)
    rescue Mongoid::Errors::Validations => e
      message = e.document.errors.full_messages.uniq.join(', ') + '.'
      logger.error "#{team.name}: #{e.message} (#{message}), ignored."
    rescue StandardError => e
      logger.error "#{team.name}: #{e.class}, #{e.message}, ignored."
    end

    def reset!
      @services.values.to_a.each do |team|
        stop!(team)
      end
    end
  end
end
