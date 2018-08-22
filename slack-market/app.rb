module SlackMarket
  class App < SlackRubyBotServer::App
    include Celluloid

    def after_start!
      once_and_every 60 * 60 * 24 do
        check_subscribed_teams!
        deactivate_asleep_teams!
      end
    end

    private

    def once_and_every(tt)
      yield
      every tt do
        yield
      end
    end

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

    def check_subscribed_teams!
      Team.where(subscribed: true, :stripe_customer_id.ne => nil).each do |team|
        begin
          customer = Stripe::Customer.retrieve(team.stripe_customer_id)
          customer.subscriptions.each do |subscription|
            subscription_name = "#{subscription.plan.name} (#{ActiveSupport::NumberHelper.number_to_currency(subscription.plan.amount.to_f / 100)})"
            logger.info "Checking #{team} subscription to #{subscription_name}, #{subscription.status}."
            case subscription.status
            when 'past_due'
              logger.warn "Subscription for #{team} is #{subscription.status}, notifying."
              team.inform! "Your subscription to #{subscription_name} is past due. #{team.update_cc_text}"
            when 'canceled', 'unpaid'
              logger.warn "Subscription for #{team} is #{subscription.status}, downgrading."
              team.inform! "Your subscription to #{subscription.plan.name} (#{ActiveSupport::NumberHelper.number_to_currency(subscription.plan.amount.to_f / 100)}) was canceled and your team has been downgraded. Thank you for being a customer!"
              team.update_attributes!(subscribed: false)
            end
          end
        rescue StandardError => e
          logger.warn "Error checking team #{team} subscription, #{e.message}."
        end
      end
    end
  end
end
