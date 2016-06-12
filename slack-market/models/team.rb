class Team
  field :api, type: Boolean, default: false
  field :dollars, type: Boolean, default: false
  field :charts, type: Boolean, default: true

  scope :api, -> { where(api: true) }
end
