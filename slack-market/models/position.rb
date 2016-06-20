class Position
  include Mongoid::Document
  include Mongoid::Timestamps

  field :symbol, type: String
  field :name, type: String

  field :purchased_price_cents, type: Integer
  field :purchased_at, type: DateTime

  field :sold_price_cents, type: Integer
  field :sold_at, type: DateTime

  belongs_to :user, index: true
  validates_presence_of :user

  scope :open, -> { where(sold_at: nil) }
  scope :closed, -> { where(:sold_at.ne => nil) }

  def to_s
    "#{user}: #{symbol}, purchased_price_cents=~#{purchased_price_cents}, purchased=#{purchased_at}, sold_price_cents=#{sold_price_cents}, sold=#{sold_at}"
  end

  def percent_from(last_trade_price)
    return unless last_trade_price
    100 - (purchased_price_cents * 100 / last_trade_price.to_f).to_f.round(2)
  end

  def display(last_trade_price)
    pc = percent_from(last_trade_price)
    [
      "*#{symbol}*",
      if pc.nil?
        nil
      elsif pc == 0
        ':blue_book:'
      elsif pc > 0
        "+#{pc}% :green_book:"
      elsif pc < 0
        "#{pc}% :closed_book:"
      end
    ].compact.join(' ')
  end
end
