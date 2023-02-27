namespace :update_data do
  desc 'Looking for new promotions'

  task categorize: :environment do
    Product.categorize_existing_products
  end

  task fora: :environment do
    company = Company.find_by(name: 'FORA')

    Collector::Fora.update(company)
  end
end
