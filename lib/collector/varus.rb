module Collector
  # rubocop:disable Metrics/AbcSize
  class Varus
    def self.update(company)
      browser = Watir::Browser.new(:chrome, options: { args: ['--ignore-certificate-errors'] },
                                            http_client: { read_timeout: 360 })

      browser.goto(company.endpoint)
      sleep 5

      last_page = 0

      while browser.button(class: 'sf-button products__load-more').present?
        if browser.div(class: 'sf-product-card__out-of-stock').present?
          last_page = browser.url.split('=').second.to_i
          break
        end

        browser.button(class: 'sf-button products__load-more').click
        sleep 2
      end

      current_page = 1
      while current_page <= last_page
        browser = Watir::Browser.new(:chrome, options: { args: ['--ignore-certificate-errors'] },
                                              http_client: { read_timeout: 360 })
        browser.goto("#{company.endpoint}?page=#{current_page}")
        assign_products(browser.divs(class: 'm-category-list__item'), company)
        current_page += 1
        browser.close
      end
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Rails/Blank
    def self.assign_products(products, company)
      new_products = []
      existing_products = []

      products.each do |div|
        next if div.span(class: 'sf-price__regular').present?
        next if div.div(class: 'sf-product-card__out-of-stock').present?
        next unless div.span(class: 'sf-product-card__badge_text').present?

        product = {
          url: div.a.href,
          name: div.p(class: 'sf-product-card__title').text.tr('«»®', ''),
          amount: div.p(class: 'sf-product-card__quantity').text,
          price_in_uah: div.del(class: 'sf-price__old').text.to_f,
          discount_price_in_uah: div.ins(class: 'sf-price__special').text.to_f,
          discount: div.span(class: 'sf-product-card__badge_text').text.split(' ').first.tr('-%', '').to_i,
          expire_on: compose_expiration(div),
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
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Rails/Blank

    def self.compose_expiration(div)
      if div.span(class: 'sf-product-card__badge_text').present?
        day_and_month = div.span(class: 'sf-product-card__badge_text').text.split(' ').third

        if day_and_month.split('.').second.to_i < Date.current.month
          Date.strptime(day_and_month + ".#{Date.current.year + 1}", '%d.%m.%Y')
        else
          Date.strptime(day_and_month + ".#{Date.current.year}", '%d.%m.%Y')
        end
      else
        Date.current
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
