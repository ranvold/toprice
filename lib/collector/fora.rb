module Collector
  # rubocop:disable Metrics/AbcSize
  class Fora
    PROMO_EXPIRATION_KEY = 'Пропозиція діє:'.freeze
    EXTEND_PAGE = 'Завантажити ще'.freeze

    def self.update(company)
      browser = Watir::Browser.new :firefox, http_client: { read_timeout: 360 }

      browser.goto(company.endpoint)
      sleep 2

      browser.div(class: 'MuiPaper-root MuiDialog-paper')
             .button(class: 'MuiButtonBase-root MuiButton-root').click
      sleep 2

      count = browser.h1(text: 'Акції').parent.span.text.to_i
      count = [count, 24].min

      products_class_name = ''

      index = -1
      loop do
        products_class_name = browser.divs[index += 1].class_name

        break if count == browser.divs(class: products_class_name).count
      end

      while browser.span(text: EXTEND_PAGE).parent.present?
        browser.span(text: EXTEND_PAGE).parent.click
        sleep 2
      end

      assign_products(browser.divs(class: products_class_name), company)

      browser.close
    end

    def self.assign_products(products, company)
      new_products = []
      existing_products = []

      products.each do |div|
        product = {
          url: div.a.href,
          name: div.h2.text.tr('«»®', ''),
          amount: div.h2.parent.div.text,
          price_in_uah: pu = div.div(text: /\b#{PROMO_EXPIRATION_KEY}/).parent.divs[1].text.tr(',', '.').to_f,
          discount_price_in_uah: dpu = div.div(text: /\b#{PROMO_EXPIRATION_KEY}/).parent.divs[2].text.tr(',', '.').to_f,
          discount: (100 - (dpu * 100 / pu)).round,
          expire_on: Date.strptime(div.div(text: /\b#{PROMO_EXPIRATION_KEY}/).text.split.last, '%d.%m.%Y'),
          company:
        }
        if Product.exists?(url: product[:url])
          existing_products << product
        else
          product[:image] = URI.parse(div.img.src).open
          sleep 3
          new_products << product
        end
      end

      Product.add_new_products(new_products) if new_products.present?
      Product.update_existing_products(existing_products) if existing_products.present?
    end
  end
  # rubocop:enable Metrics/AbcSize
end
