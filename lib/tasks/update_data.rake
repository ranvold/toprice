namespace :update_data do
  desc 'Looking for new promotions'

  # TODO: delete after setup all categories
  task categorize: :environment do
    Product.categorize_existing_products
  end

  task fora: :environment do
    company = Company.find_by(name: 'Фора')

    Collector::Fora.update(company)
  end
end
