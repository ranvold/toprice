module Collector
  # rubocop:disable Metrics/AbcSize
  class Atb
    MONTHS = { Січня: '01', Лютого: '02', Березня: '03', Квітня: '04', Травня: '05', Червня: '06',
               Липня: '07', Серпня: '08', Вересня: '09', Жовтня: '10', Листопада: '11', Грудня: '12' }.freeze

    def self.update(company)
      browser = Watir::Browser.new :firefox, http_client: { read_timeout: 360 }

      browser.goto(company.endpoint)
      sleep 3

      products_count_before_scroll = browser.divs(class: 'item').count
      products_count_after_scroll = 0

      while products_count_after_scroll != products_count_before_scroll
        products_count_before_scroll = browser.divs(class: 'item').count
        browser.divs(class: 'item').last.scroll.to
        sleep 2
        products_count_after_scroll = browser.divs(class: 'item').count
      end

      assign_products(browser.divs(class: 'item'), company)

      browser.close
    end

    # rubocop:disable Rails/Blank
    def self.assign_products(products, company)
      new_products = []

      products.each do |div|
        next unless div.span(class: 'product-pricebefore-val').present?

        product = {
          url: div.a(class: 'image-link').href,
          name: div.h3.text.tr('«»®', ''),
          price_in_uah: div.span(class: 'product-pricebefore-val').text.to_f,
          discount_price_in_uah: div.span(class: 'product-priceafter').text.to_f,
          discount: div.span(class: 'product-discount').text.tr('-', ''),
          expire_on: parse_expiration(div),
          company:
        }

        sleep 3
        product[:image] = URI.parse(div.a(class: 'image-link').img.src).open
        new_products << product
      end

      company.products.destroy_all if new_products.present?

      Product.add_new_products(new_products) if new_products.present?
    end
    # rubocop:enable Rails/Blank

    def self.parse_expiration(div)
      date_str = div.a(class: 'discount-link').text.tr(')', '').split(' - ').second.split(' ')

      Date.strptime("#{date_str.first}.#{MONTHS[date_str.second.to_sym]}.#{date_str.third}", '%d.%m.%Y')
    end
  end
  # rubocop:enable Metrics/AbcSize
end
