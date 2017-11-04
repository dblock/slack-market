class Ticker
  include ActiveModel::Model

  attr_accessor :symbol
  attr_accessor :name
  attr_accessor :last_trade_price
  attr_accessor :change
  attr_accessor :change_in_percent

  def change_in_percent_s
    [
      change_in_percent > 0 ? '+' : '',
      format('%.2f', change_in_percent),
      '%'
    ].join
  end
end
