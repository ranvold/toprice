module Collector
  class Varus
    def self.update(company)
      browser = Watir::Browser.new :firefox, http_client: { read_timeout: 360 }

      browser.goto(company.endpoint)
      sleep 2

      # while browser.button(class: 'sf-button products__load-more').present?
      #   browser.button(class: 'sf-button products__load-more').click
      #   sleep 2
      # end

      products_nodes = browser.divs(class: 'm-category-list__item')

      new_products = []
      new_products_count = 0
      existing_products = []
      existing_products_count = 0

      products_nodes.each do |div|
        product = {
          url: div.a.href,
          name: div.p(class: 'sf-product-card__title').text.tr('«»®', ''),
          amount: div.p(class: 'sf-product-card__quantity').text,
          price_in_uah: div.del(class: 'sf-price__old').text.to_f,
          discount_price_in_uah: div.ins(class: 'sf-price__special').text.to_f,
          discount: div.div(class: 'color-primary').span.text.split(' ').first.gsub('-', ''),
          expiration: parse_expiration(div.div(class: 'color-primary').span.text.split(' ').third),
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

      debugger

      puts "Found #{new_products_count} new products to be saved"
      puts "Found #{existing_products_count} existing products to be updated"

      # Product.add_new_products(new_products) if new_products.present?
      # Product.update_existing_products(existing_products) if existing_products.present?
    end

    def self.parse_expiration(day_and_month)
      if day_and_month.split('.').second.to_i < Date.current.month
        Date.strptime(day_and_month + ".#{Date.current.year + 1}", '%d.%m.%Y')
      else
        Date.strptime(day_and_month + ".#{Date.current.year}", '%d.%m.%Y')
      end
    end
  end
end
