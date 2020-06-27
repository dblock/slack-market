class Team
  field :api, type: Boolean, default: false
  field :dollars, type: Boolean, default: false
  field :charts, type: Boolean, default: true
  field :bots, type: Boolean, default: false

  field :stripe_customer_id, type: String
  field :subscribed, type: Boolean, default: false
  field :subscribed_at, type: DateTime

  scope :api, -> { where(api: true) }

  after_update :subscribed!

  def asleep?(dt = 2.weeks)
    return false unless subscription_expired?

    time_limit = Time.now - dt
    created_at <= time_limit
  end

  def tags
    [
      subscribed? ? 'subscribed' : 'trial',
      stripe_customer_id? ? 'paid' : nil
    ].compact
  end

  def inform!(message)
    channels = slack_client.channels_list['channels'].select { |channel| channel['is_member'] }
    return unless channels.any?

    channel = channels.first
    logger.info "Sending '#{message}' to #{self} on ##{channel['name']}."
    slack_client.chat_postMessage(text: message, channel: channel['id'], as_user: true)
  end

  def subscription_expired?
    return false if subscribed?

    (created_at + 1.week) < Time.now
  end

  def subscribe_text
    [trial_expired_text, subscribe_team_text].compact.join(' ')
  end

  def update_cc_text
    "Update your credit card info at #{SlackRubyBotServer::Service.url}/update_cc?team_id=#{team_id}."
  end

  def slack_client
    @slack_client ||= Slack::Web::Client.new(token: token)
  end

  private

  def trial_expired_text
    return unless subscription_expired?

    'Your trial subscription has expired.'
  end

  def subscribe_team_text
    "Subscribe your team for $1.99 a month at #{SlackRubyBotServer::Service.url}/subscribe?team_id=#{team_id}."
  end

  SUBSCRIBED_TEXT = <<~EOS.freeze
    Your team has been subscribed, enjoy all features. Thanks for supporting open-source!
    Follow https://twitter.com/playplayio for news and updates.
  EOS

  def subscribed!
    return unless subscribed? && subscribed_changed?

    inform! SUBSCRIBED_TEXT
  end
end
