class Product < ApplicationRecord
  belongs_to :category
  belongs_to :company

  has_one_attached :image

  validates :name, presence: true
  validates :price, presence: true
  validates :discount, presence: true
  validates :discount_price, presence: true
  validates :url, presence: true, uniqueness: true
  validates :expire, presence: true

  default_scope { order(discount: :desc) }

  def price_in_uah
    price.to_f / 100
  end

  def discount_price_in_uah
    discount_price.to_f / 100
  end

  def price_in_uah=(val)
    self.price = val * 100
  end

  def discount_price_in_uah=(val)
    self.discount_price = val * 100
  end

  def self.categorize(new_products)
    categories = Category.where.not(name: 'Інше')

    categorized_products = []

    categories.each do |category|
      selected_products = new_products.select { |product| product[:name].downcase.match(/#{category.keywords}/) }

      selected_products.each { |product| product[:category] = category }

      categorized_products.concat(selected_products)
    end

    new_products = new_products.reject { |p| categorized_products.include? p }

    if new_products.present?
      other_category = Category.find_by(name: 'Інше')

      new_products.each { |product| product[:category] = other_category }

      categorized_products.concat(new_products)
    end

    categorized_products
  end

  def self.categorize_existing_products
    new_products = Product.all

    categories = Category.where.not(name: 'Інше')

    categorized_products = []

    categories.each do |category|
      selected_products = new_products.select { |product| product.name.downcase.match(/#{category.keywords}/) }

      selected_products.each { |product| product.category = category }

      categorized_products.concat(selected_products)

      new_products = new_products.reject { |p| selected_products.include? p }
    end

    if new_products.present?
      other_category = Category.find_by(name: 'Інше')

      new_products.each { |product| product.category = other_category }

      categorized_products.concat(new_products)
    end

    categorized_products.each { |p| puts "#{p.category.name} - #{p.name}" }

    categorized_products.each(&:save)
  end

  def self.update_existing_products(parsed_existing_products)
    parsed_existing_products.each do |product|
      Product.find_by(url: product[:url]).update(
        price_in_uah: product[:price_in_uah],
        discount: product[:discount],
        discount_price_in_uah: product[:discount_price_in_uah],
        expire: product[:expire]
      )
    end
  end

  def self.add_new_products(parsed_products)
    products = categorize(parsed_products)

    products.each do |product|
      new_product = Product.new(
        name: product[:name],
        price_in_uah: product[:price_in_uah],
        discount: product[:discount],
        discount_price_in_uah: product[:discount_price_in_uah],
        url: product[:url],
        expire: product[:expire],
        company: product[:company],
        category: product[:category],
        amount: product[:amount]
      )

      new_product.image.attach(io: product[:image],
                               filename: "#{product[:url].split('/').last}_#{product[:company].name.downcase}.png")
      new_product.save
    end
  end
end
