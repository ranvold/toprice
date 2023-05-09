module Collector
  # rubocop:disable Metrics/AbcSize
  class Silpo
    def self.update(company)
      browser = Watir::Browser.new :firefox, http_client: { read_timeout: 360 }

      browser.goto(company.endpoint)
      sleep 3

      products_count_before_scroll = browser.divs(class: 'product-list__item').count
      products_count_after_scroll = 0

      while products_count_after_scroll != products_count_before_scroll
        products_count_before_scroll = browser.divs(class: 'product-list__item').count
        browser.divs(class: 'product-list__item').last.scroll.to
        sleep 2
        products_count_after_scroll = browser.divs(class: 'product-list__item').count
      end

      assign_products(browser.divs(class: 'product-list__item'), company)

      browser.close
    end

    # rubocop:disable Metrics/MethodLength
    def self.assign_products(products, company)
      new_products = []
      existing_products = []
      promotions = {}

      products.each do |div|
        product = {
          url: div.a.href,
          name: div.div(class: 'product-list__item-title').text.tr('«»®', ''),
          amount: div.div(class: 'product-list__item-weight').text,
          price_in_uah: pu = div.div(class: 'product-price__old').text.to_f,
          discount_price_in_uah: dpu = div.div(class: 'product-price__integer').text.to_f +
                                       (div.div(class: 'product-price__fraction').text.to_f / 100),
          discount: (100 - (dpu * 100 / pu)).round,
          expire_on: parse_expiration(div, promotions),
          company:
        }
        if Product.exists?(url: product[:url])
          existing_products << product
        else
          sleep 3
          product[:image] = URI.parse(div.img.src).open
          new_products << product
        end
      end

      Product.add_new_products(new_products) if new_products.present?
      Product.update_existing_products(existing_products) if existing_products.present?
    end
    # rubocop:enable Metrics/MethodLength

    def self.parse_expiration(div, existing_promo)
      promo = div.div(class: 'product-list__item-promotion-label').style

      if existing_promo.key?(promo)
        existing_promo[promo]
      else
        tmp_window = Watir::Browser.new :firefox, http_client: { read_timeout: 360 }
        tmp_window.goto(div.a.href)
        sleep 3
        expire_on = Date.strptime(tmp_window.div(class: 'bubble-info__content').spans[1].text, '%d.%m.%Y')
        tmp_window.close
        existing_promo[promo] = expire_on
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
