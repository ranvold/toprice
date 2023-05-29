FactoryBot.define do
  factory :category do
    name { Faker::Name.unique.name }
    keywords_by_semicolons { "#{Faker::Food.ingredient};" }
  end
end
