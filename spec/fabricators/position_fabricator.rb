Fabricator(:position) do
  user { User.first || Fabricate(:user) }
  symbol { Faker::Lorem.word.upcase }
  purchased_at { Time.now.utc }
  purchased_price_cents { Faker::Number.decimal(2, 2) * 100 }
end

Fabricator(:closed_position, from: :position) do
  sold_at { Time.now.utc }
  sold_price_cents { Faker::Number.decimal(2, 2) * 100 }
end
