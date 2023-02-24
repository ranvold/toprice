namespace :update_data do
  desc 'Looking for new promotions'

  task fora: :environment do
    company = Company.find_by(name: 'FORA')

    Collector::Fora.update(company)
  end
end
