module Collector
  class Fora
    def self.update(company)
      browser = Watir::Browser.new :firefox, http_client: { read_timeout: 360 }

      browser.goto(company.endpoint)
      sleep 2

      browser.div(class: 'MuiPaper-root MuiDialog-paper')
             .button(class: 'MuiButtonBase-root MuiButton-root').click
      sleep 2

      # browser.h1(text: 'Акції').parent.span.text.to_i
      count = 24

      products_class_name = ''

      index = -1
      while count != browser.divs(class: products_class_name).count
        products_class_name = browser.divs[index += 1].class_name
      end

      while browser.span(text: 'Завантажити ще').parent.present?
        browser.span(text: 'Завантажити ще').parent.click
        sleep 2
      end

      products_nodes = browser.divs(class: products_class_name)

      new_products = []
      new_products_count = 0
      existing_products = []
      existing_products_count = 0

      promo_expiration_key = 'Пропозиція діє:'

      products_nodes.each do |div|
        product = {
          url: div.a.href,
          name: div.h2.text.tr('«»®', ''),
          amount: div.h2.parent.div.text,
          price_in_uah: price = div.div(text: /\b#{promo_expiration_key}/).parent.divs[1].text.tr(',', '.').to_f,
          discount_price_in_uah: discount_price = div.div(text: /\b#{promo_expiration_key}/).parent.divs[2].text.tr(',', '.').to_f,
          discount: (100 - (discount_price * 100 / price)).round,
          expiration: Date.strptime(div.div(text: /\b#{promo_expiration_key}/).text.split.last, '%d.%m.%Y'),
          company:
        }
        if Product.exists?(url: product[:url])
          existing_products << product
          existing_products_count += 1
        else
          product[:image] = URI.parse(div.img.src).open
          sleep 3
          new_products << product
          new_products_count += 1
        end
      end

      browser.close

      puts "Found #{new_products_count} new products to be saved"
      puts "Found #{existing_products_count} existing products to be updated"

      Product.add_new_products(new_products) if new_products.present?
      Product.update_existing_products(existing_products) if existing_products.present?
    end
  end
end
