class Team
  field :api, type: Boolean, default: false
  field :dollars, type: Boolean, default: false
  field :charts, type: Boolean, default: true

  field :stripe_customer_id, type: String
  field :subscribed, type: Boolean, default: false
  field :subscribed_at, type: DateTime

  scope :api, -> { where(api: true) }

  def asleep?(dt = 2.weeks)
    return false unless subscription_expired?
    time_limit = Time.now - dt
    created_at <= time_limit
  end

  def inform!(message, gif_name = nil)
    client = Slack::Web::Client.new(token: token)
    channels = client.channels_list['channels'].select { |channel| channel['is_member'] }
    return unless channels.any?
    channel = channels.first
    logger.info "Sending '#{message}' to #{self} on ##{channel['name']}."
    gif = begin
      Giphy.random(gif_name)
    rescue StandardError => e
      logger.warn "Giphy.random: #{e.message}"
      nil
    end if gif_name && gifs?
    text = [message, gif && gif.image_url.to_s].compact.join("\n")
    client.chat_postMessage(text: text, channel: channel['id'], as_user: true)
  end

  def subscription_expired?
    return false if subscribed?
    (created_at + 1.week) < Time.now
  end

  def subscribe_text
    [trial_expired_text, subscribe_team_text].compact.join(' ')
  end

  private

  def trial_expired_text
    return unless subscription_expired?
    'Your trial subscription has expired.'
  end

  def subscribe_team_text
    "Subscribe your team for $1.99 a month at https://market.playplay.io/subscribe?team_id=#{team_id}."
  end
end
