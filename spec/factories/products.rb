FactoryBot.define do
  factory :product do
    name { Faker::Food.ingredient }
    price_in_uah { Faker::Number.decimal(l_digits: 2) }
    discount { Faker::Number.within(range: 10..70) }
    discount_price_in_uah { (100 - discount) / 100.to_f * price_in_uah }
    url { Faker::Internet.unique.url }
    expire_on { Faker::Date.forward(days: 7) }
    company
    category
  end
end
