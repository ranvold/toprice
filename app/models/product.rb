class Product < ApplicationRecord
  belongs_to :category
  belongs_to :company

  has_one_attached :image

  validates :name, presence: true
  validates :price, presence: true
  validates :discount, presence: true
  validates :discount_price, presence: true
  validates :url, presence: true, uniqueness: true
  validates :expire_on, presence: true

  scope :current, -> { where('expire_on >= ?', Date.current) }
  scope :order_by_discount, -> { order(discount: :desc) }
  scope :by_company, ->(ids) { where('company_id in (?)', ids) }
  scope :by_category, ->(ids) { where('category_id in (?)', ids) }
  scope :by_name, ->(name) { where('name ~* ?', "\\m#{name}") }

  # rubocop:disable Metrics/AbcSize
  def self.categorize(new_products)
    categories = Category.where.not(name: 'Інше').order_by_id

    categorized_products = []

    categories.each do |category|
      selected_products = new_products.select { |product| product[:name].match(/#{category.keywords}/i) }

      selected_products.each { |product| product[:category] = category }

      categorized_products.concat(selected_products)

      new_products -= selected_products
    end

    if new_products.present?
      other_category = Category.find_by(name: 'Інше')

      new_products.each { |product| product[:category] = other_category }

      categorized_products.concat(new_products)
    end

    categorized_products
  end
  # rubocop:enable Metrics/AbcSize

  # TODO: delete after setup all categories
  # rubocop:disable Metrics/AbcSize
  def self.categorize_existing_products
    new_products = Product.all

    categories = Category.where.not(name: 'Інше').order_by_id

    categorized_products = []

    categories.each do |category|
      selected_products = new_products.select { |product| product.name.match(/#{category.keywords}/i) }

      selected_products.each { |product| product.category = category }

      categorized_products.concat(selected_products)

      new_products -= selected_products
    end

    if new_products.present?
      other_category = Category.find_by(name: 'Інше')

      new_products.each { |product| product.category = other_category }

      categorized_products.concat(new_products)
    end

    categorized_products.each { |p| puts "#{p.category.name} - #{p.name}" }

    categorized_products.each(&:save)
  end
  # rubocop:enable Metrics/AbcSize

  def self.update_existing_products(parsed_existing_products)
    parsed_existing_products.each do |product|
      Product.find_by(url: product[:url]).update(
        price_in_uah: product[:price_in_uah],
        discount: product[:discount],
        discount_price_in_uah: product[:discount_price_in_uah],
        expire_on: product[:expire_on]
      )
    end
  end

  def self.add_new_products(parsed_products)
    products = categorize(parsed_products)

    products.each do |product|
      new_product = Product.new(product_params(product))

      image_filename = "#{product[:url].split('/').last}_#{product[:company].name.downcase}.png"
      new_product.image.attach(io: product[:image], filename: image_filename)

      new_product.save
    end
  end

  def self.product_params(product)
    {
      name: product[:name],
      price_in_uah: product[:price_in_uah],
      discount: product[:discount],
      discount_price_in_uah: product[:discount_price_in_uah],
      url: product[:url],
      expire_on: product[:expire_on],
      company: product[:company],
      category: product[:category],
      amount: product[:amount]
    }
  end

  def price_in_uah
    price.to_f / 100
  end

  def discount_price_in_uah
    discount_price.to_f / 100
  end

  def price_in_uah=(val)
    self.price = (val * 100).to_i
  end

  def discount_price_in_uah=(val)
    self.discount_price = (val * 100).to_i
  end
end
