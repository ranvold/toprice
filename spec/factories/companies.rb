FactoryBot.define do
  factory :company do
    name { Faker::Name.unique.name }
    endpoint { Faker::Internet.unique.url }
  end
end
