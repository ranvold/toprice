module Collector
  # rubocop:disable Metrics/AbcSize
  class Varus
    def self.update(company)
      browser = Watir::Browser.new :firefox, http_client: { read_timeout: 360 }

      browser.goto(company.endpoint)
      sleep 2

      while browser.button(class: 'sf-button products__load-more').present?
        browser.button(class: 'sf-button products__load-more').click
        sleep 2
      end

      assign_products(browser.divs(class: 'm-category-list__item'), company)

      browser.close
    end

    def self.assign_products(products, company)
      new_products = existing_products = []

      products.each do |div|
        next if div.span(class: 'sf-price__regular').present?

        product = {
          url: div.a.href,
          name: div.p(class: 'sf-product-card__title').text.tr('«»®', ''),
          amount: div.p(class: 'sf-product-card__quantity').text,
          price_in_uah: div.del(class: 'sf-price__old').text.to_f,
          discount_price_in_uah: div.ins(class: 'sf-price__special').text.to_f,
          discount: div.span(class: 'sf-product-card__badge_text').text.split(' ').first.tr('-%', '').to_i,
          expire_on: compose_expiration(div.span(class: 'sf-product-card__badge_text').text.split(' ').third),
          company:
        }
        if Product.exists?(url: product[:url])
          existing_products << product
        else
          div.scroll.to
          sleep 3
          product[:image] = URI.parse(div.img.src).open
          new_products << product
        end
      end

      Product.add_new_products(new_products) if new_products.present?
      Product.update_existing_products(existing_products) if existing_products.present?
    end

    def self.compose_expiration(day_and_month)
      if day_and_month.split('.').second.to_i < Date.current.month
        Date.strptime(day_and_month + ".#{Date.current.year + 1}", '%d.%m.%Y')
      else
        Date.strptime(day_and_month + ".#{Date.current.year}", '%d.%m.%Y')
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
