class Team
  field :api, type: Boolean, default: false
  field :dollars, type: Boolean, default: false
  field :charts, type: Boolean, default: true

  field :stripe_customer_id, type: String
  field :premium, type: Boolean, default: false

  scope :api, -> { where(api: true) }

  def premium_text
    "This is a premium feature. Subscribe your team for $9.99 a year at https://market.playplay.io/subscribe?team_id=#{team_id}."
  end
end
