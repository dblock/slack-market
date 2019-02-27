class Team
  field :api, type: Boolean, default: false
  field :dollars, type: Boolean, default: false
  field :charts, type: Boolean, default: true

  field :access_token, type: String
  field :bot_user_id, type: String
  field :activated_user_id, type: String

  field :stripe_customer_id, type: String
  field :subscribed, type: Boolean, default: false
  field :subscribed_at, type: DateTime

  scope :api, -> { where(api: true) }

  after_update :subscribed!
  after_save :activated!

  def asleep?(dt = 2.weeks)
    return false unless subscription_expired?
    time_limit = Time.now - dt
    created_at <= time_limit
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
    "Update your credit card info at #{SlackMarket::Service.url}/update_cc?team_id=#{team_id}."
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
    "Subscribe your team for $1.99 a month at #{SlackMarket::Service.url}/subscribe?team_id=#{team_id}."
  end

  SUBSCRIBED_TEXT = <<~EOS.freeze
    Your team has been subscribed, enjoy all features. Thanks for supporting open-source!
    Follow https://twitter.com/playplayio for news and updates.
EOS

  def subscribed!
    return unless subscribed? && subscribed_changed?
    inform! SUBSCRIBED_TEXT
    signup_to_mailing_list!
  end

  def activated!
    return unless active? && activated_user_id && bot_user_id
    return unless active_changed? || activated_user_id_changed?
    signup_to_mailing_list!
  end

  # mailing list management

  def mailchimp_client
    return unless ENV.key?('MAILCHIMP_API_KEY')
    @mailchimp_client ||= Mailchimp.connect(ENV['MAILCHIMP_API_KEY'])
  end

  def mailchimp_list
    return unless mailchimp_client
    rerurn unless ENV.key?('MAILCHIMP_LIST_ID')
    @mailchimp_list ||= mailchimp_client.lists(ENV['MAILCHIMP_LIST_ID'])
  end

  def signup_to_mailing_list!
    return unless activated_user_id
    profile ||= Hashie::Mash.new(slack_client.users_info(user: activated_user_id)).user.profile
    return unless profile
    return unless mailchimp_list
    tags = ['marketbot', subscribed? ? 'subscribed' : 'trial', stripe_customer_id? ? 'paid' : nil].compact
    member = mailchimp_list.members.where(email_address: profile.email).first
    if member
      member_tags = member.tags.map { |tag| tag['name'] }.sort
      tags = (member_tags + tags).uniq
      return if tags == member_tags
    end
    mailchimp_list.members.create_or_update(
      name: profile.name,
      email_address: profile.email,
      unique_email_id: "#{team_id}-#{activated_user_id}",
      status: member ? member.status : 'pending',
      tags: tags,
      merge_fields: {
        'FNAME' => profile.first_name.to_s,
        'LNAME' => profile.last_name.to_s,
        'BOT' => 'Market'
      }
    )
    logger.info "Subscribed #{profile.email} to #{ENV['MAILCHIMP_LIST_ID']}, #{self}."
  rescue StandardError => e
    logger.error "Error subscribing #{self} to #{ENV['MAILCHIMP_LIST_ID']}: #{e.message}, #{e.errors}"
  end
end
