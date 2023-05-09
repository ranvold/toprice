namespace :update_data do
  desc 'Looking for new promotions'

  # TODO: delete after setup all categories
  task categorize: :environment do
    Product.categorize_existing_products
  end

  task fora: :environment do
    company = Company.find_by(name: 'ФОРА')

    Collector::Fora.update(company)
  end

  task varus: :environment do
    company = Company.find_by(name: 'ВАРУС')

    Collector::Varus.update(company)
  end

  task silpo: :environment do
    company = Company.find_by(name: 'СІЛЬПО')

    Collector::Silpo.update(company)
  end

  task atb: :environment do
    company = Company.find_by(name: 'АТБ')

    Collector::Atb.update(company)
  end
end
