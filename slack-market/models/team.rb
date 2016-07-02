class Team
  field :api, type: Boolean, default: false
  field :dollars, type: Boolean, default: false
  field :charts, type: Boolean, default: true

  field :stripe_customer_id, type: String
  field :subscribed, type: Boolean, default: false
  field :subscribed_at, type: DateTime

  scope :api, -> { where(api: true) }

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
